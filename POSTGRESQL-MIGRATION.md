# PostgreSQL Migration Guide

## Overview

Lania SSO telah bermigrasi dari MySQL 8.0 ke PostgreSQL 16+. Dokumen ini menjelaskan perubahan yang terjadi dan cara melakukan deployment dengan PostgreSQL.

## Perubahan Database

### 1. Database Provider

- **Sebelum**: MySQL 8.0.30
- **Sesudah**: PostgreSQL 14+

### 2. File SQL

- **MySQL Files** (deprecated):
  - `lania_sso.sql` - Schema MySQL lama
  - `lania_common.sql` - Schema MySQL lama dengan 91k+ lines data regional Indonesia
- **PostgreSQL Files** (gunakan ini):
  - `lania_sso_postgres.sql` - Schema PostgreSQL lengkap dengan seed data
  - `lania_common_postgres.sql` - Schema PostgreSQL dengan minimal seed data

### 3. Perubahan Type Mapping

| MySQL Type         | PostgreSQL Type                 | Keterangan                  |
| ------------------ | ------------------------------- | --------------------------- |
| `@db.LongText`     | `@db.Text`                      | Large text/JSON storage     |
| `@db.DateTime(0)`  | `@db.Timestamp(6)`              | Datetime with microseconds  |
| `@db.Timestamp(0)` | `@db.Timestamp(6)`              | Timestamp with microseconds |
| `AUTO_INCREMENT`   | `SERIAL` / `uuid_generate_v4()` | Auto-incrementing IDs       |
| `ENGINE=InnoDB`    | (removed)                       | Not needed in PostgreSQL    |
| Backticks `` ` ``  | Double quotes `"`               | Identifier quoting          |
| `SHOW TABLES`      | `\dt`                           | List tables command         |

### 4. Perubahan Stored Procedures

**MySQL Syntax** (lama):

```sql
DELIMITER ;;
CREATE PROCEDURE cleanup_old_audit_logs()
BEGIN
  DELETE FROM audit_logs WHERE created_at < DATE_SUB(NOW(), INTERVAL 3 MONTH);
END;;
DELIMITER ;
```

**PostgreSQL Syntax** (baru):

```sql
CREATE OR REPLACE FUNCTION cleanup_old_audit_logs()
RETURNS void AS $$
BEGIN
    DELETE FROM audit_logs
    WHERE created_at < CURRENT_TIMESTAMP - INTERVAL '3 months';
END;
$$ LANGUAGE plpgsql;
```

### 5. Event Scheduler

**MySQL** menggunakan Event Scheduler built-in:

```sql
CREATE EVENT cleanup_audit_logs_event
ON SCHEDULE EVERY 1 MONTH
DO CALL cleanup_old_audit_logs();
```

**PostgreSQL** memerlukan extension `pg_cron` (optional):

```sql
-- Install pg_cron extension first
CREATE EXTENSION IF NOT EXISTS pg_cron;

-- Schedule cleanup
SELECT cron.schedule('cleanup_audit_logs', '0 2 1 * *', 'SELECT cleanup_old_audit_logs()');
```

**Catatan**: Jika tidak ada `pg_cron`, gunakan cron system level atau task scheduler aplikasi.

## Setup PostgreSQL

### 1. Install PostgreSQL

**Ubuntu/Debian**:

```bash
sudo apt update
sudo apt install postgresql postgresql-contrib
sudo systemctl start postgresql
sudo systemctl enable postgresql
```

**Windows**:
Download installer dari https://www.postgresql.org/download/windows/

**MacOS**:

```bash
brew install postgresql@14
brew services start postgresql@14
```

### 2. Konfigurasi User dan Database

```bash
# Login sebagai postgres user
sudo -u postgres psql

# Atau di Windows
psql -U postgres
```

```sql
-- Create application user
CREATE USER lania_user WITH PASSWORD 'your_secure_password';

-- Grant permissions
ALTER USER lania_user CREATEDB;
```

### 3. Restore Database

```bash
# Method 1: Using psql with -d flag (recommended)
psql -U postgres -d lania_sso -f lania_sso_postgres.sql
psql -U postgres -d lania_common -f lania_common_postgres.sql

# Method 2: Two-step process
# First create databases
psql -U postgres -c "CREATE DATABASE lania_sso;"
psql -U postgres -c "CREATE DATABASE lania_common;"

# Then restore tables
psql -U postgres -d lania_sso -f lania_sso_postgres.sql
psql -U postgres -d lania_common -f lania_common_postgres.sql

# Grant permissions
psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE lania_sso TO lania_user;"
psql -U postgres -c "GRANT ALL PRIVILEGES ON DATABASE lania_common TO lania_user;"
```

### 4. Verifikasi Installation

```bash
# Connect to database
psql -U lania_user -d lania_sso

# List tables
\dt

# Check functions
\df

# Check data
SELECT * FROM core_services;
SELECT * FROM users;

# Exit
\q
```

## Connection String

### Development (.env.local)

```env
DATABASE_URL="postgresql://lania_user:your_password@localhost:5432/lania_sso?schema=public"
```

### Staging (.env.staging)

```env
DATABASE_URL="postgresql://lania_user:secure_password@staging-db.internal:5432/lania_sso?schema=public"
```

### Production (.env.production)

```env
DATABASE_URL="postgresql://lania_user:very_secure_password@production-db.internal:5432/lania_sso?schema=public&connection_limit=10&pool_timeout=30"
```

### Connection String dengan SSL

```env
DATABASE_URL="postgresql://lania_user:password@host:5432/lania_sso?schema=public&sslmode=require"
```

## Prisma Migration

### Generate Prisma Client

```bash
npx prisma generate
```

**PENTING**:

- ✅ `npx prisma generate` AMAN - Hanya generate TypeScript client
- ⚠️ JANGAN jalankan `npx prisma migrate dev` di production
- ⚠️ JANGAN jalankan `npx prisma db push` di production

### Development Workflow

```bash
# 1. Update schema.prisma jika ada perubahan
# 2. Generate client
npx prisma generate

# 3. Jika ada perubahan schema, buat SQL migration manual
# 4. Test di development database dulu
# 5. Apply ke production via SQL file
```

## Migrasi Data dari MySQL

Jika Anda masih memiliki data di MySQL dan perlu migrasi:

### Opsi 1: pgLoader (Recommended)

```bash
# Install pgLoader
sudo apt install pgloader

# Migrate
pgloader mysql://root:password@localhost/lania_sso \
          postgresql://lania_user:password@localhost/lania_sso
```

### Opsi 2: Manual Export/Import

```bash
# Export dari MySQL
mysqldump -u root -p --no-create-info --complete-insert lania_sso > data_mysql.sql

# Convert syntax (manual atau script)
# - Replace backticks dengan double quotes atau hapus
# - Adjust data types
# - Convert AUTO_INCREMENT

# Import ke PostgreSQL
psql -U lania_user -d lania_sso -f data_postgres.sql
```

### Opsi 3: Application Level Migration

Gunakan aplikasi Node.js untuk membaca dari MySQL dan write ke PostgreSQL.

## Regional Data (lania_common)

File `lania_common.sql` asli berisi 91,861 lines dengan data:

- 34 Provinsi Indonesia
- 514 Kabupaten/Kota
- 7,254 Kecamatan
- 83,820 Desa/Kelurahan

File `lania_common_postgres.sql` hanya berisi structure dan minimal seed data.

### Cara Import Full Regional Data

**Jika Anda memerlukan data regional lengkap**:

1. Gunakan pgLoader untuk migrasi langsung dari MySQL
2. Atau export specific tables dari MySQL:

```bash
mysqldump -u root -p lania_common \
  reg_provinces reg_regencies reg_districts reg_villages \
  --no-create-info --complete-insert > regional_data.sql
```

3. Convert dan import ke PostgreSQL

## Troubleshooting

### Connection Refused

```bash
# Check PostgreSQL status
sudo systemctl status postgresql

# Check listening port
sudo netstat -tlnp | grep 5432
```

### Authentication Failed

```bash
# Edit pg_hba.conf
sudo nano /etc/postgresql/14/main/pg_hba.conf

# Add line:
# local   all   lania_user   md5

# Restart
sudo systemctl restart postgresql
```

### Permission Denied

```sql
-- Grant all permissions
GRANT ALL PRIVILEGES ON DATABASE lania_sso TO lania_user;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO lania_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO lania_user;
```

### Slow Query Performance

```sql
-- Create missing indexes
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);
CREATE INDEX idx_sessions_user_id ON sessions(user_id);

-- Analyze tables
ANALYZE audit_logs;
ANALYZE sessions;
```

### Out of Memory

Edit `postgresql.conf`:

```conf
shared_buffers = 256MB
effective_cache_size = 1GB
maintenance_work_mem = 64MB
```

## Monitoring

### Check Database Size

```sql
SELECT pg_size_pretty(pg_database_size('lania_sso'));
```

### Check Table Sizes

```sql
SELECT
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;
```

### Active Connections

```sql
SELECT count(*) FROM pg_stat_activity WHERE datname = 'lania_sso';
```

### Long Running Queries

```sql
SELECT
  pid,
  now() - pg_stat_activity.query_start AS duration,
  query,
  state
FROM pg_stat_activity
WHERE state != 'idle'
  AND now() - pg_stat_activity.query_start > interval '5 seconds';
```

## Performance Tips

1. **Connection Pooling**: Gunakan PgBouncer atau connection pooling di Prisma
2. **Indexes**: Pastikan semua foreign keys memiliki index
3. **VACUUM**: Jalankan VACUUM ANALYZE secara berkala
4. **Monitoring**: Setup monitoring dengan pg_stat_statements
5. **Backup**: Setup automated backup menggunakan pg_dump atau WAL archiving

## Backup & Restore

### Backup

```bash
# Full backup
pg_dump -U lania_user -d lania_sso -F c -f lania_sso_backup.dump

# SQL format
pg_dump -U lania_user -d lania_sso > lania_sso_backup.sql

# Specific tables
pg_dump -U lania_user -d lania_sso -t users -t tenants > tables_backup.sql
```

### Restore

```bash
# From custom format
pg_restore -U lania_user -d lania_sso lania_sso_backup.dump

# From SQL
psql -U lania_user -d lania_sso < lania_sso_backup.sql
```

### Automated Backup Script

```bash
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backup/postgres"
pg_dump -U lania_user -d lania_sso -F c -f "$BACKUP_DIR/lania_sso_$DATE.dump"
# Keep only last 7 days
find $BACKUP_DIR -name "lania_sso_*.dump" -mtime +7 -delete
```

## Reference

- PostgreSQL Documentation: https://www.postgresql.org/docs/
- Prisma PostgreSQL Guide: https://www.prisma.io/docs/concepts/database-connectors/postgresql
- pg_cron Extension: https://github.com/citusdata/pg_cron
- pgLoader: https://pgloader.io/

## Checklist Migration

- [ ] PostgreSQL 14+ installed and running
- [ ] Database user created with proper permissions
- [ ] `lania_sso_postgres.sql` restored successfully
- [ ] `lania_common_postgres.sql` restored successfully
- [ ] `.env` updated with PostgreSQL connection string
- [ ] `npx prisma generate` executed
- [ ] Application starts without errors
- [ ] Login functionality works
- [ ] Tenant switching works
- [ ] Session management works
- [ ] Audit logs recording properly
- [ ] Performance acceptable
- [ ] Backup strategy implemented
