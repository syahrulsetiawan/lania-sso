# PostgreSQL Optimization Guide - Lania SSO

## PostgreSQL Extensions untuk Optimasi

### 1. **pg_stat_statements** ⭐ (HIGHLY RECOMMENDED)

**Purpose**: Query performance monitoring dan analysis

**Installation**:

```sql
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
```

**Configuration** (`postgresql.conf`):

```conf
shared_preload_libraries = 'pg_stat_statements'
pg_stat_statements.track = all
pg_stat_statements.max = 10000
```

**Usage**:

```sql
-- Top 10 slowest queries
SELECT
  query,
  calls,
  total_exec_time,
  mean_exec_time,
  max_exec_time
FROM pg_stat_statements
ORDER BY mean_exec_time DESC
LIMIT 10;

-- Most frequently called queries
SELECT query, calls
FROM pg_stat_statements
ORDER BY calls DESC
LIMIT 10;

-- Reset statistics
SELECT pg_stat_statements_reset();
```

**Benefits untuk Lania SSO**:

- Identify slow authentication queries
- Monitor audit log write performance
- Optimize tenant switching queries
- Track session management performance

---

### 2. **pgcrypto** ⭐ (SECURITY)

**Purpose**: Advanced cryptographic functions

**Installation**:

```sql
CREATE EXTENSION IF NOT EXISTS pgcrypto;
```

**Usage untuk SSO**:

```sql
-- Generate secure tokens
SELECT encode(gen_random_bytes(32), 'hex');

-- Hash passwords (jika tidak pakai bcrypt di aplikasi)
SELECT crypt('password', gen_salt('bf', 10));

-- Verify password
SELECT crypt('password', stored_hash) = stored_hash;

-- Encrypt sensitive data
SELECT pgp_sym_encrypt('sensitive_data', 'encryption_key');
SELECT pgp_sym_decrypt(encrypted_column, 'encryption_key');
```

**Use Cases di Lania SSO**:

- Generate refresh tokens
- Generate password reset tokens
- Encrypt tenant sensitive info (tax_number, connection strings)
- Additional layer for email verification tokens

---

### 3. **pg_trgm** ⭐ (SEARCH OPTIMIZATION)

**Purpose**: Trigram-based fuzzy search dan similarity

**Installation**:

```sql
CREATE EXTENSION IF NOT EXISTS pg_trgm;
```

**Usage**:

```sql
-- Create GIN index for fast text search
CREATE INDEX idx_users_name_trgm ON users USING GIN (name gin_trgm_ops);
CREATE INDEX idx_tenants_name_trgm ON tenants USING GIN (name gin_trgm_ops);

-- Fuzzy search users
SELECT * FROM users
WHERE name % 'jhon';  -- Finds "John", "Johan", etc.

-- Similarity search
SELECT name, similarity(name, 'search_term') as sim
FROM users
WHERE similarity(name, 'search_term') > 0.3
ORDER BY sim DESC;
```

**Benefits**:

- Fast user search with typo tolerance
- Tenant name search
- Email search with variations
- Better autocomplete performance

---

### 4. **uuid-ossp** ✅ (ALREADY PLANNED)

**Purpose**: UUID generation (sudah ada di SQL files)

**Installation**:

```sql
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
```

**Usage**:

```sql
-- Generate UUID v4
SELECT uuid_generate_v4();

-- Use in INSERT
INSERT INTO users (id, name, email)
VALUES (uuid_generate_v4(), 'John', 'john@example.com');
```

**Current Status**: Sudah diinclude di `lania_sso_postgres.sql` dan `lania_common_postgres.sql`

---

### 5. **pg_cron** (SCHEDULED TASKS)

**Purpose**: Database-level cron jobs

**Installation**:

```bash
# Ubuntu/Debian
sudo apt install postgresql-16-cron

# Configure postgresql.conf
shared_preload_libraries = 'pg_cron'
cron.database_name = 'lania_sso'
```

```sql
CREATE EXTENSION IF NOT EXISTS pg_cron;
```

**Usage untuk Lania SSO**:

```sql
-- Daily cleanup expired tokens (2 AM)
SELECT cron.schedule('cleanup-expired-tokens', '0 2 * * *', $$
  DELETE FROM refresh_tokens WHERE expires_at < NOW();
  DELETE FROM password_reset_tokens WHERE expires_at < NOW();
  DELETE FROM email_verification_tokens WHERE expires_at < NOW();
$$);

-- Monthly cleanup old audit logs (1st of month, 3 AM)
SELECT cron.schedule('cleanup-audit-logs', '0 3 1 * *', $$
  DELETE FROM audit_logs WHERE created_at < NOW() - INTERVAL '3 months';
$$);

-- Daily cleanup old sessions (2:30 AM)
SELECT cron.schedule('cleanup-old-sessions', '30 2 * * *', $$
  DELETE FROM sessions
  WHERE revoked_at IS NOT NULL
    AND revoked_at < NOW() - INTERVAL '30 days';
$$);

-- Weekly cleanup failed login attempts (Sunday 3 AM)
SELECT cron.schedule('cleanup-failed-logins', '0 3 * * 0', $$
  DELETE FROM failed_login_attempts
  WHERE attempted_at < NOW() - INTERVAL '90 days';
$$);

-- View scheduled jobs
SELECT * FROM cron.job;

-- View job run history
SELECT * FROM cron.job_run_details ORDER BY start_time DESC LIMIT 10;

-- Unschedule a job
SELECT cron.unschedule('cleanup-expired-tokens');
```

**Alternative**: Jika tidak bisa install `pg_cron`, gunakan Node.js cron jobs dengan `node-cron` package.

---

### 6. **pg_partman** (TABLE PARTITIONING)

**Purpose**: Automated table partitioning management

**Use Case**: Partition `audit_logs` by date

**Installation**:

```bash
sudo apt install postgresql-16-partman
```

```sql
CREATE EXTENSION IF NOT EXISTS pg_partman;
```

**Setup for audit_logs**:

```sql
-- Convert audit_logs to partitioned table
CREATE TABLE audit_logs_partitioned (
    LIKE audit_logs INCLUDING ALL
) PARTITION BY RANGE (created_at);

-- Create partitions automatically
SELECT partman.create_parent(
    p_parent_table := 'public.audit_logs_partitioned',
    p_control := 'created_at',
    p_type := 'native',
    p_interval := 'monthly',
    p_premake := 3
);

-- Automatic maintenance (add to cron)
SELECT partman.run_maintenance();
```

**Benefits**:

- Faster queries on audit_logs (filter by date)
- Easy to drop old partitions (delete old logs)
- Better query performance for recent data
- Reduced index size

---

### 7. **pgvector** (AI/ML FEATURES)

**Purpose**: Vector similarity search (untuk future AI features)

**Installation**:

```bash
sudo apt install postgresql-16-pgvector
```

```sql
CREATE EXTENSION IF NOT EXISTS vector;
```

**Potential Use Cases**:

```sql
-- Store user behavior vectors
ALTER TABLE users ADD COLUMN behavior_vector vector(384);

-- Similarity search for user recommendations
SELECT * FROM users
ORDER BY behavior_vector <-> '[0.1, 0.2, ...]'::vector
LIMIT 5;
```

**Future Applications**:

- User behavior analysis
- Anomaly detection in login patterns
- Smart user recommendations
- AI-powered security alerts

---

### 8. **pg_repack** (MAINTENANCE)

**Purpose**: Online table reorganization without locks

**Installation**:

```bash
sudo apt install postgresql-16-repack
```

**Usage**:

```bash
# Repack bloated tables
pg_repack -d lania_sso -t audit_logs
pg_repack -d lania_sso -t sessions

# Repack entire database
pg_repack -d lania_sso
```

**Benefits**:

- Reclaim disk space from deleted rows
- Rebuild indexes without downtime
- Improve table performance
- No locks (can run in production)

---

### 9. **pg_stat_kcache** (CACHE MONITORING)

**Purpose**: Kernel-level cache statistics

**Installation**:

```bash
sudo apt install postgresql-16-pg-stat-kcache
```

```sql
CREATE EXTENSION IF NOT EXISTS pg_stat_kcache;
```

**Usage**:

```sql
-- See cache hit rates
SELECT * FROM pg_stat_kcache;

-- Identify queries with poor cache performance
SELECT
  query,
  shared_blks_hit,
  shared_blks_read,
  shared_blks_hit::float / (shared_blks_hit + shared_blks_read) as cache_hit_ratio
FROM pg_stat_statements
JOIN pg_stat_kcache USING (queryid)
WHERE shared_blks_hit + shared_blks_read > 0
ORDER BY cache_hit_ratio ASC
LIMIT 10;
```

---

### 10. **PostGIS** (LOCATION FEATURES)

**Purpose**: Geographic data support

**Use Case**: Jika mau track user location accurately

**Installation**:

```bash
sudo apt install postgresql-16-postgis-3
```

```sql
CREATE EXTENSION IF NOT EXISTS postgis;
```

**Enhanced Location Tracking**:

```sql
-- Add geometry column to sessions
ALTER TABLE sessions
ADD COLUMN location_point geometry(Point, 4326);

-- Store precise location
UPDATE sessions
SET location_point = ST_SetSRID(ST_MakePoint(longitude, latitude), 4326)
WHERE latitude IS NOT NULL;

-- Find users within radius
SELECT * FROM sessions
WHERE ST_DWithin(
  location_point::geography,
  ST_SetSRID(ST_MakePoint(106.8456, -6.2088), 4326)::geography,
  5000  -- 5km radius
);

-- Distance between logins
SELECT
  s1.id,
  ST_Distance(
    s1.location_point::geography,
    s2.location_point::geography
  ) / 1000 as distance_km
FROM sessions s1
JOIN sessions s2 ON s1.user_id = s2.user_id
WHERE s1.id != s2.id;
```

**Security Use Case**:

- Detect impossible travel (login from Jakarta then Singapore in 1 hour)
- Geographic-based security alerts
- Location-based access control

---

## PostgreSQL Tools & Utilities

### 1. **pgAdmin 4** (GUI MANAGEMENT)

**Purpose**: Visual database management

**Installation**:

```bash
# Ubuntu
sudo apt install pgadmin4
```

**Features**:

- Visual query builder
- Table data editor
- Query performance analyzer
- Backup/restore GUI
- Connection management

---

### 2. **PgBouncer** ⭐ (CONNECTION POOLING)

**Purpose**: Lightweight connection pooler

**Why Needed**:

- NestJS creates many database connections
- PostgreSQL has connection limit (default 100)
- Reduce connection overhead
- Better performance under load

**Installation**:

```bash
sudo apt install pgbouncer
```

**Configuration** (`/etc/pgbouncer/pgbouncer.ini`):

```ini
[databases]
lania_sso = host=localhost port=5432 dbname=lania_sso
lania_common = host=localhost port=5432 dbname=lania_common

[pgbouncer]
listen_addr = 127.0.0.1
listen_port = 6432
auth_type = md5
auth_file = /etc/pgbouncer/userlist.txt
pool_mode = transaction
max_client_conn = 1000
default_pool_size = 25
reserve_pool_size = 5
server_idle_timeout = 600
```

**Update .env**:

```env
# Connect to PgBouncer instead of PostgreSQL directly
DATABASE_URL="postgresql://lania_user:password@localhost:6432/lania_sso?schema=public"
```

**Benefits**:

- Handle 1000+ concurrent connections
- Reduce database load
- Faster connection times
- Better resource utilization

---

### 3. **pg_activity** (MONITORING)

**Purpose**: Real-time PostgreSQL monitoring

**Installation**:

```bash
pip install pg_activity
```

**Usage**:

```bash
pg_activity -U postgres -d lania_sso
```

**Features**:

- Real-time query monitoring
- Active connections
- Lock monitoring
- Database size tracking
- Kill queries directly

---

### 4. **pgBackRest** (BACKUP SOLUTION)

**Purpose**: Enterprise-grade backup and restore

**Installation**:

```bash
sudo apt install pgbackrest
```

**Configuration** (`/etc/pgbackrest/pgbackrest.conf`):

```ini
[global]
repo1-path=/var/lib/pgbackrest
repo1-retention-full=7

[lania_sso]
pg1-path=/var/lib/postgresql/16/main
```

**Usage**:

```bash
# Full backup
pgbackrest --stanza=lania_sso backup --type=full

# Incremental backup
pgbackrest --stanza=lania_sso backup --type=incr

# Restore
pgbackrest --stanza=lania_sso restore
```

---

### 5. **pgBadger** (LOG ANALYZER)

**Purpose**: Advanced log analysis and reports

**Installation**:

```bash
sudo apt install pgbadger
```

**Usage**:

```bash
# Generate report from logs
pgbadger /var/log/postgresql/postgresql-16-main.log -o report.html

# Open report.html in browser
```

**Reports Include**:

- Slowest queries
- Most frequent queries
- Connection statistics
- Lock statistics
- Temporary files usage
- Checkpoint activity

---

### 6. **pgDash** (MONITORING DASHBOARD)

**Purpose**: Comprehensive monitoring platform

**Website**: https://pgdash.io/

**Features**:

- Real-time metrics
- Query performance
- Table statistics
- Index usage
- Alerts and notifications
- Historical data

---

## Performance Configuration

### Recommended postgresql.conf Settings

```conf
# Memory Settings (adjust based on your RAM)
shared_buffers = 4GB              # 25% of total RAM
effective_cache_size = 12GB       # 75% of total RAM
work_mem = 64MB                   # For sorting/joins
maintenance_work_mem = 512MB      # For VACUUM, CREATE INDEX

# Write Performance
wal_buffers = 16MB
checkpoint_completion_target = 0.9
max_wal_size = 4GB
min_wal_size = 1GB

# Query Planner
random_page_cost = 1.1            # For SSD
effective_io_concurrency = 200    # For SSD

# Connection Settings
max_connections = 200
superuser_reserved_connections = 3

# Logging (for performance analysis)
log_min_duration_statement = 1000  # Log queries > 1 second
log_line_prefix = '%t [%p]: [%l-1] user=%u,db=%d,app=%a,client=%h '
log_checkpoints = on
log_connections = on
log_disconnections = on
log_lock_waits = on

# Extensions
shared_preload_libraries = 'pg_stat_statements,pg_cron'

# Autovacuum (important for audit_logs)
autovacuum = on
autovacuum_max_workers = 4
autovacuum_naptime = 30s
```

---

## Recommended Implementation Priority

### Phase 1 - Essential (Implement Now) ✅

1. **uuid-ossp** - Already in SQL files
2. **pg_stat_statements** - Query monitoring
3. **PgBouncer** - Connection pooling
4. **pgcrypto** - Security enhancements

### Phase 2 - Performance (Next Sprint) 📊

5. **pg_trgm** - Search optimization
6. **pg_cron** - Automated cleanups
7. **pg_activity** - Real-time monitoring
8. **pgBackRest** - Backup strategy

### Phase 3 - Advanced (Future) 🚀

9. **pg_partman** - If audit_logs grows huge
10. **PostGIS** - If need location features
11. **pgvector** - For AI/ML features
12. **pg_repack** - Maintenance optimization

---

## Code Examples for Application

### 1. Using pgcrypto for Token Generation

**src/auth/auth.service.ts**:

```typescript
// Instead of crypto.randomBytes, use PostgreSQL pgcrypto
async generateSecureToken(): Promise<string> {
  const result = await this.prisma.$queryRaw<[{ token: string }]>`
    SELECT encode(gen_random_bytes(32), 'hex') as token
  `;
  return result[0].token;
}
```

### 2. Using pg_trgm for User Search

**src/auth/auth.service.ts**:

```typescript
async searchUsers(query: string) {
  return this.prisma.$queryRaw`
    SELECT *, similarity(name, ${query}) as sim
    FROM users
    WHERE similarity(name, ${query}) > 0.3
    ORDER BY sim DESC
    LIMIT 10
  `;
}
```

### 3. Monitoring Query Performance

**src/common/interceptors/performance.interceptor.ts**:

```typescript
@Injectable()
export class PerformanceInterceptor implements NestInterceptor {
  async intercept(context: ExecutionContext, next: CallHandler) {
    const start = Date.now();

    return next.handle().pipe(
      tap(async () => {
        const duration = Date.now() - start;

        // Log slow queries to database
        if (duration > 1000) {
          await this.logSlowQuery(context, duration);
        }
      }),
    );
  }
}
```

---

## Monitoring Queries

```sql
-- Check extension status
SELECT * FROM pg_available_extensions WHERE name LIKE 'pg_%';

-- View installed extensions
SELECT * FROM pg_extension;

-- Database size
SELECT pg_size_pretty(pg_database_size('lania_sso'));

-- Table sizes with indexes
SELECT
  schemaname,
  tablename,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename)) AS total_size,
  pg_size_pretty(pg_relation_size(schemaname||'.'||tablename)) AS table_size,
  pg_size_pretty(pg_total_relation_size(schemaname||'.'||tablename) -
                 pg_relation_size(schemaname||'.'||tablename)) AS indexes_size
FROM pg_tables
WHERE schemaname = 'public'
ORDER BY pg_total_relation_size(schemaname||'.'||tablename) DESC;

-- Index usage statistics
SELECT
  schemaname,
  tablename,
  indexname,
  idx_scan,
  idx_tup_read,
  idx_tup_fetch
FROM pg_stat_user_indexes
ORDER BY idx_scan ASC;

-- Unused indexes (candidates for removal)
SELECT
  schemaname,
  tablename,
  indexname,
  pg_size_pretty(pg_relation_size(indexrelid)) as index_size
FROM pg_stat_user_indexes
WHERE idx_scan = 0
  AND indexrelname NOT LIKE '%_pkey';
```

---

## Summary & Recommendations

### Must Have ⭐⭐⭐

- **pg_stat_statements** - Track query performance
- **PgBouncer** - Connection pooling (critical untuk production)
- **pgcrypto** - Enhanced security
- **pgBackRest** - Reliable backups

### Should Have ⭐⭐

- **pg_trgm** - Better search UX
- **pg_cron** - Automated maintenance
- **pg_activity** - Real-time monitoring
- **pgBadger** - Log analysis

### Nice to Have ⭐

- **pg_partman** - When audit_logs > 10M rows
- **PostGIS** - If need location features
- **pgvector** - For future AI features
- **pg_repack** - For large table maintenance

### Estimated Performance Gains

- **PgBouncer**: 30-50% better connection handling
- **pg_stat_statements**: Identify 80% of performance issues
- **pg_trgm**: 10x faster search queries
- **pg_cron**: Automated maintenance = consistent performance
- **Proper indexes**: 100-1000x faster queries

---

Mau saya implementasikan yang mana dulu? Rekomendasi saya mulai dari:

1. pg_stat_statements
2. PgBouncer
3. pgcrypto
4. pg_trgm
