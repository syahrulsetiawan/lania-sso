# 🚀 DEPLOYMENT GUIDE - LANIAKEA SSO

**Version**: 1.0.0  
**Last Updated**: November 13, 2025  
**Environment**: Production Ready ✅

---

## 📋 TABLE OF CONTENTS

1. [Prerequisites](#prerequisites)
2. [Development Environment Setup](#development-environment-setup)
3. [Staging Deployment](#staging-deployment)
4. [Production Deployment](#production-deployment)
5. [Database Setup](#database-setup)
6. [Application Startup](#application-startup)
7. [Verification & Testing](#verification--testing)
8. [Post-Deployment Tasks](#post-deployment-tasks)
9. [Monitoring & Maintenance](#monitoring--maintenance)
10. [Troubleshooting](#troubleshooting)

---

## ✅ PREREQUISITES

### System Requirements

- **OS**: Linux/macOS/Windows with WSL2
- **Node.js**: v20.0.0 or higher
- **npm**: v10.0.0 or higher
- **PostgreSQL**: v16.0 or higher
- **Git**: v2.0 or higher

### Verify Installation

```bash
# Check Node.js version
node --version
# Expected: v20.x.x or higher

# Check npm version
npm --version
# Expected: v10.x.x or higher

# Check PostgreSQL version
psql --version
# Expected: psql (PostgreSQL) 16.x or higher

# Check Git version
git --version
# Expected: git version 2.x or higher
```

### Required Privileges

- PostgreSQL superuser or user with privileges:
  - CREATE DATABASE
  - CREATE TABLE
  - CREATE FUNCTION
  - CREATE EXTENSION
  - GRANT (if creating new user)

### Network Requirements

- Port 8001 available (Backend API)
- Port 5432 available (PostgreSQL)
- Outbound SMTP access (for email notifications)

---

## 🏗️ DEVELOPMENT ENVIRONMENT SETUP

### Step 1: Clone Repository

```bash
# Clone the repository
git clone https://github.com/syahrulsetiawan/lania-sso.git
cd lania-sso

# Verify branch
git branch
# Should show: * development
```

### Step 2: Install Dependencies

```bash
# Install npm packages
npm install

# Verify installation
npm list @nestjs/core @prisma/client fastify

# Expected output:
# lania-sso@0.0.1
# ├── @nestjs/core@11.0.1
# ├── @prisma/client@6.19.0
# ├── @nestjs/platform-fastify@11.1.8
# └── fastify@5.6.2
```

### Step 3: Setup Environment Variables

```bash
# Copy example file
cp .env.example .env

# Edit .env file with your configuration
nano .env
# OR
code .env

# Essential variables to update:
# NODE_ENV=development
# PORT=8001
# JWT_SECRET=your-super-secret-key-minimum-32-chars
# DATABASE_URL=mysql://root:password@localhost:3306/lania_sso
```

### Step 4: Create & Configure PostgreSQL Database

```bash
# Create user for the application
psql -U postgres << EOF
CREATE USER lania_user WITH PASSWORD 'secure_password';
GRANT ALL PRIVILEGES ON DATABASE lania_sso TO lania_user;
GRANT ALL PRIVILEGES ON DATABASE lania_common TO lania_user;
EOF

# Then update .env:
# DATABASE_URL=postgresql://lania_user:secure_password@localhost:5432/lania_sso?schema=public
```

### Step 5: Restore Database from SQL Files

```bash
# Create databases first
psql -U postgres << EOF
CREATE DATABASE lania_sso LOCALE_PROVIDER = 'libc' LOCALE = 'en_US.UTF-8' TEMPLATE template0;
CREATE DATABASE lania_common LOCALE_PROVIDER = 'libc' LOCALE = 'en_US.UTF-8' TEMPLATE template0;
GRANT ALL PRIVILEGES ON DATABASE lania_sso TO lania_user;
GRANT ALL PRIVILEGES ON DATABASE lania_common TO lania_user;
EOF

# Import SQL schema files
psql -U lania_user -d lania_sso < lania_sso_postgres.sql
psql -U lania_user -d lania_common < lania_common_postgres.sql

# Verify tables were created
psql -U lania_user -d lania_sso -c "\dt"

# Expected output:
# 18 tables: audit_logs, core_licenses, core_services, etc.

# Verify functions and extensions
psql -U lania_user -d lania_sso -c "\df"
psql -U lania_user -d lania_sso -c "\dx"
```

### Step 6: Generate Prisma Client

```bash
# Generate Prisma client (does NOT modify database, only generates client code)
npx prisma generate

# Verify schema sync
npx prisma validate

# Expected: ✓ Schema is valid!

# NOTE: We do NOT run "prisma migrate" because:
# - Database schema already exists from SQL files
# - npx prisma generate only creates TypeScript client, doesn't touch database
# - Schema drift is avoided by using the exact SQL files
```

### Step 7: Run Development Server

```bash
# Start development server with watch mode
npm run start:dev

# Expected output:
# [Nest] 12345  - 11/13/2025, 10:30:00 AM     LOG [NestFactory] Starting Nest application...
# [Nest] 12345  - 11/13/2025, 10:30:01 AM     LOG [InstanceLoader] PrismaModule dependencies initialized
# [Nest] 12345  - 11/13/2025, 10:30:02 AM     LOG [InstanceLoader] AuthModule dependencies initialized
# [Nest] 12345  - 11/13/2025, 10:30:03 AM     LOG [InstanceLoader] TenantsModule dependencies initialized
# [Nest] 12345  - 11/13/2025, 10:30:03 AM     LOG [NestApplication] Fastify server registered
# [Nest] 12345  - 11/13/2025, 10:30:04 AM     LOG [NestApplication] Listening on 0.0.0.0:8001 🚀
```

### Step 8: Verify Development Setup

```bash
# Test API health endpoint
curl http://localhost:8001/api/v1/health

# Expected response:
# {"status":"ok","timestamp":"2025-11-13T10:30:00Z"}

# Access Swagger documentation
# http://localhost:8001/api/v1/docs
```

---

## 🌐 STAGING DEPLOYMENT

### Step 1: Prepare Staging Environment

```bash
# SSH into staging server
ssh deploy@staging.server.com

# Create application directory
mkdir -p /opt/lania-sso
cd /opt/lania-sso

# Clone repository
git clone --branch development https://github.com/syahrulsetiawan/lania-sso.git .
```

### Step 2: Install Dependencies on Staging

```bash
# Install Node.js (if not already installed)
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt-get install -y nodejs

# Install npm dependencies
npm install --production

# Verify installation
npm list @nestjs/core
```

### Step 3: Configure Staging Environment

```bash
# Create .env file with staging values
cat > .env << EOF
NODE_ENV=staging
PORT=8001
HOST=0.0.0.0
API_PREFIX=api/v1

# CORS
CORS_ORIGIN=https://staging-frontend.example.com,https://staging-admin.example.com
CORS_CREDENTIALS=true

# Rate Limiting
RATE_LIMIT_MAX=100
RATE_LIMIT_WINDOW=15m

# JWT Configuration
JWT_SECRET=staging-super-secret-jwt-key-change-this-minimum-32-characters
JWT_EXPIRES_IN=1h
JWT_REFRESH_EXPIRES_IN=7d

# Database
DATABASE_URL=mysql://staging_user:secure_password@staging-db.internal:3306/lania_sso

# Security
MAX_FAILED_LOGIN_ATTEMPTS=5
PASSWORD_RESET_EXPIRATION_MINUTES=60
EOF

# Set proper permissions
chmod 600 .env
```

### Step 4: Setup Staging Database

```bash
# Create application user first
psql -U postgres << EOF
-- Create application user
CREATE USER staging_user WITH PASSWORD 'secure_password';

-- Create databases
CREATE DATABASE lania_sso LOCALE_PROVIDER = 'libc' LOCALE = 'en_US.UTF-8' TEMPLATE template0;
CREATE DATABASE lania_common LOCALE_PROVIDER = 'libc' LOCALE = 'en_US.UTF-8' TEMPLATE template0;

-- Grant privileges
GRANT ALL PRIVILEGES ON DATABASE lania_sso TO staging_user;
GRANT ALL PRIVILEGES ON DATABASE lania_common TO staging_user;
EOF

# Restore database from SQL files
psql -U staging_user -d lania_sso < lania_sso_postgres.sql
psql -U staging_user -d lania_common < lania_common_postgres.sql

# Verify tables, functions, and extensions
psql -U staging_user -d lania_sso -c "\dt"
psql -U staging_user -d lania_sso -c "\df"
psql -U staging_user -d lania_sso -c "\dx"
```

### Step 5: Build Application for Staging

```bash
# Generate Prisma client (only generates TypeScript client, does NOT modify database)
npx prisma generate

# Build TypeScript
npm run build

# Expected output:
# [14:45:23] Found 0 errors. Cheers! ✨

# NOTE: We do NOT run migrations because database already restored from SQL files
```

### Step 6: Setup Process Manager (PM2)

```bash
# Install PM2 globally
sudo npm install -g pm2

# Create PM2 ecosystem config
cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [
    {
      name: 'lania-sso-staging',
      script: 'dist/main.js',
      instances: 1,
      exec_mode: 'cluster',
      env: {
        NODE_ENV: 'staging',
        PORT: 8001,
      },
      error_file: 'logs/err.log',
      out_file: 'logs/out.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      merge_logs: true,
      max_memory_restart: '1G',
      watch: false,
      ignore_watch: ['node_modules', 'dist', 'logs'],
      max_restarts: 10,
      min_uptime: '10s',
      autorestart: true,
    },
  ],
};
EOF

# Start with PM2
pm2 start ecosystem.config.js

# Setup PM2 to start on boot
pm2 startup
sudo env PATH=$PATH:/usr/bin /usr/lib/node_modules/pm2/bin/pm2 startup systemd -u deploy --hp /home/deploy
pm2 save

# Verify PM2
pm2 list
pm2 logs lania-sso-staging
```

### Step 7: Setup Nginx Reverse Proxy

```bash
# Install Nginx (if not already installed)
sudo apt-get install -y nginx

# Create Nginx config
sudo tee /etc/nginx/sites-available/lania-sso-staging << 'EOF'
server {
    listen 80;
    server_name staging-api.example.com;

    # Redirect HTTP to HTTPS
    return 301 https://$server_name$request_uri;
}

server {
    listen 443 ssl http2;
    server_name staging-api.example.com;

    # SSL Certificate (use Let's Encrypt)
    ssl_certificate /etc/letsencrypt/live/staging-api.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/staging-api.example.com/privkey.pem;

    # Security headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;

    # Logging
    access_log /var/log/nginx/lania-sso-staging-access.log;
    error_log /var/log/nginx/lania-sso-staging-error.log;

    # Proxy settings
    location / {
        proxy_pass http://localhost:8001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_cache_bypass $http_upgrade;

        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;
    }
}
EOF

# Enable site
sudo ln -s /etc/nginx/sites-available/lania-sso-staging /etc/nginx/sites-enabled/

# Test Nginx config
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx
```

### Step 8: Setup SSL Certificate

```bash
# Install Certbot
sudo apt-get install -y certbot python3-certbot-nginx

# Get SSL certificate from Let's Encrypt
sudo certbot certonly --nginx -d staging-api.example.com

# Setup auto-renewal
sudo systemctl enable certbot.timer
```

### Step 9: Verify Staging Deployment

```bash
# Check application status
pm2 status

# Check application logs
pm2 logs lania-sso-staging --lines 50

# Test API endpoint
curl https://staging-api.example.com/api/v1/health

# Test login endpoint
curl -X POST https://staging-api.example.com/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "usernameOrEmail": "superadmin",
    "password": "password",
    "deviceName": "Deployment Test",
    "rememberMe": false
  }'
```

---

## 🔴 PRODUCTION DEPLOYMENT

### Pre-Production Checklist

```bash
# ✅ Code Review
- All changes reviewed and approved
- No debug code in production branch
- All tests passing

# ✅ Database Backup
- Full backup taken
- Backup verified restorable
- Backup stored offsite

# ✅ Performance Testing
- Load testing completed
- Memory usage acceptable
- Response times within SLA

# ✅ Security Scanning
- Security audit completed
- Dependencies checked for vulnerabilities
- No critical issues found
```

### Step 1: Prepare Production Environment

```bash
# SSH into production server
ssh deploy@production.server.com

# Create application directory
mkdir -p /opt/laniakea/lania-sso
cd /opt/laniakea/lania-sso

# Clone main production branch
git clone --branch main https://github.com/syahrulsetiawan/lania-sso.git .

# Verify production branch
git log --oneline -5
```

### Step 2: Install Production Dependencies

```bash
# Install production dependencies only
npm install --omit=dev

# Verify versions
npm list @nestjs/core @prisma/client

# Check for vulnerabilities
npm audit --audit-level=moderate

# Fix vulnerabilities if needed
npm audit fix
```

### Step 3: Configure Production Environment

```bash
# Create secure .env file
cat > .env << 'EOF'
NODE_ENV=production
PORT=8001
HOST=0.0.0.0
API_PREFIX=api/v1

# CORS - Production domains only
CORS_ORIGIN=https://app.example.com,https://admin.example.com
CORS_CREDENTIALS=true

# Rate Limiting - Stricter in production
RATE_LIMIT_MAX=50
RATE_LIMIT_WINDOW=15m

# JWT Configuration - MUST CHANGE
JWT_SECRET=production-super-secret-jwt-key-32-characters-minimum-change-this
JWT_EXPIRES_IN=1h
JWT_REFRESH_EXPIRES_IN=7d

# Database - Production instance
DATABASE_URL=postgresql://prod_user:production_secure_password@prod-db-01.internal:5432/lania_sso?schema=public

# Security
MAX_FAILED_LOGIN_ATTEMPTS=5
PASSWORD_RESET_EXPIRATION_MINUTES=60

# Monitoring
LOG_LEVEL=info
EOF

# Restrict file permissions
chmod 600 .env
chown deploy:deploy .env
```

### Step 4: Setup Production Database

```bash
# Create application user with restricted privileges
psql -U postgres -h prod-db-01.internal << EOF
-- Create application user with restricted privileges
CREATE USER prod_user WITH PASSWORD 'production_secure_password';

-- Create databases
CREATE DATABASE lania_sso LOCALE_PROVIDER = 'libc' LOCALE = 'en_US.UTF-8' TEMPLATE template0;
CREATE DATABASE lania_common LOCALE_PROVIDER = 'libc' LOCALE = 'en_US.UTF-8' TEMPLATE template0;

-- Grant application privileges
GRANT ALL PRIVILEGES ON DATABASE lania_sso TO prod_user;
GRANT ALL PRIVILEGES ON DATABASE lania_common TO prod_user;
EOF

# Restore database from SQL files
psql -U prod_user -h prod-db-01.internal -d lania_sso < lania_sso_postgres.sql
psql -U prod_user -h prod-db-01.internal -d lania_common < lania_common_postgres.sql

# Verify tables, functions, and extensions
psql -U prod_user -h prod-db-01.internal -d lania_sso -c "\dt"
psql -U prod_user -h prod-db-01.internal -d lania_sso -c "\df"
psql -U prod_user -h prod-db-01.internal -d lania_sso -c "\dx"
```

### Step 5: Build for Production

```bash
# Generate Prisma client (only generates TypeScript client, does NOT modify database)
npx prisma generate

# Build optimized build
npm run build

# Verify build
ls -la dist/

# Expected files:
# dist/main.js
# dist/app.module.js
# dist/auth/...
# dist/tenants/...

# NOTE: We do NOT run "prisma migrate" because:
# - Database already restored from SQL files (lania_sso_postgres.sql & lania_common_postgres.sql)
# - npx prisma generate only creates client code for TypeScript
# - No database modifications needed
```

### Step 6: Setup PM2 for Production

```bash
# Install PM2 globally
sudo npm install -g pm2

# Create production ecosystem config
cat > ecosystem.config.js << 'EOF'
module.exports = {
  apps: [
    {
      name: 'lania-sso-prod',
      script: 'dist/main.js',
      instances: 'max',
      exec_mode: 'cluster',
      env: {
        NODE_ENV: 'production',
        PORT: 8001,
      },
      error_file: 'logs/error.log',
      out_file: 'logs/output.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      merge_logs: true,
      max_memory_restart: '2G',
      watch: false,
      ignore_watch: ['node_modules', 'dist', 'logs'],
      max_restarts: 10,
      min_uptime: '10s',
      autorestart: true,
      listen_timeout: 3000,
    },
  ],
};
EOF

# Start production application
pm2 start ecosystem.config.js --name lania-sso-prod

# Setup PM2 to survive reboot
pm2 startup systemd -u deploy
pm2 save

# Verify running
pm2 status
pm2 logs lania-sso-prod
```

### Step 7: Setup Production Nginx with SSL

```bash
# Create Nginx config for production
sudo tee /etc/nginx/sites-available/lania-sso << 'EOF'
# HTTP redirect to HTTPS
server {
    listen 80;
    listen [::]:80;
    server_name api.example.com;

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }

    location / {
        return 301 https://$server_name$request_uri;
    }
}

# HTTPS production server
server {
    listen 443 ssl http2;
    listen [::]:443 ssl http2;
    server_name api.example.com;

    # SSL Configuration
    ssl_certificate /etc/letsencrypt/live/api.example.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/api.example.com/privkey.pem;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    # Security Headers
    add_header Strict-Transport-Security "max-age=31536000; includeSubDomains; preload" always;
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "no-referrer-when-downgrade" always;
    add_header Content-Security-Policy "default-src 'self'" always;

    # Logging
    access_log /var/log/nginx/lania-sso-access.log combined buffer=32k flush=1m;
    error_log /var/log/nginx/lania-sso-error.log warn;

    # Rate limiting
    limit_req_zone $binary_remote_addr zone=api_limit:10m rate=10r/s;
    limit_req zone=api_limit burst=20 nodelay;

    # Proxy configuration
    location / {
        proxy_pass http://localhost:8001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto https;
        proxy_cache_bypass $http_upgrade;

        # Timeouts
        proxy_connect_timeout 60s;
        proxy_send_timeout 60s;
        proxy_read_timeout 60s;

        # Buffering
        proxy_buffering on;
        proxy_buffer_size 32k;
        proxy_buffers 8 32k;
    }
}
EOF

# Enable site
sudo ln -s /etc/nginx/sites-available/lania-sso /etc/nginx/sites-enabled/

# Test configuration
sudo nginx -t

# Reload Nginx
sudo systemctl reload nginx
```

### Step 8: Setup SSL with Certbot

```bash
# Install Certbot
sudo apt-get install -y certbot python3-certbot-nginx

# Get certificate from Let's Encrypt
sudo certbot certonly --nginx -d api.example.com

# Setup auto-renewal
sudo systemctl enable certbot.timer
sudo systemctl start certbot.timer

# Verify renewal
sudo certbot renew --dry-run
```

### Step 9: Setup Monitoring & Logging

```bash
# Create log directory
mkdir -p logs

# Setup log rotation
sudo tee /etc/logrotate.d/lania-sso << 'EOF'
/opt/laniakea/lania-sso/logs/*.log {
    daily
    rotate 14
    compress
    delaycompress
    notifempty
    create 0640 deploy deploy
    sharedscripts
    postrotate
        pm2 reload lania-sso-prod > /dev/null 2>&1 || true
    endscript
}
EOF

# Setup log monitoring
sudo apt-get install -y logwatch
```

### Step 10: Setup Database Backup

```bash
# Create backup script
cat > /opt/laniakea/backup-lania-sso.sh << 'EOF'
#!/bin/bash
set -e

BACKUP_DIR="/backups/lania-sso"
DATE=$(date +%Y%m%d_%H%M%S)
DB_USER="prod_user"
DB_HOST="prod-db-01.internal"

# Create backup directory
mkdir -p $BACKUP_DIR

# Backup both databases
pg_dump -U $DB_USER -h $DB_HOST lania_sso > $BACKUP_DIR/lania_sso_$DATE.sql
pg_dump -U $DB_USER -h $DB_HOST lania_common > $BACKUP_DIR/lania_common_$DATE.sql

# Compress backups
gzip $BACKUP_DIR/lania_sso_$DATE.sql
gzip $BACKUP_DIR/lania_common_$DATE.sql

# Remove backups older than 7 days
find $BACKUP_DIR -name "*.sql.gz" -mtime +7 -delete

# Upload to S3 (optional)
# aws s3 cp $BACKUP_DIR/lania_sso_$DATE.sql.gz s3://backup-bucket/lania-sso/
# aws s3 cp $BACKUP_DIR/lania_common_$DATE.sql.gz s3://backup-bucket/lania-sso/

echo "Backup completed: $BACKUP_DIR/lania_sso_$DATE.sql.gz"
echo "Backup completed: $BACKUP_DIR/lania_common_$DATE.sql.gz"
EOF

chmod +x /opt/laniakea/backup-lania-sso.sh

# Setup cron job for daily backup at 2 AM
crontab -e
# Add: 0 2 * * * /opt/laniakea/backup-lania-sso.sh
```

### Step 11: Final Production Verification

```bash
# Check application status
pm2 status

# Check application logs
pm2 logs lania-sso-prod --lines 100

# Test API endpoints
curl -X GET https://api.example.com/api/v1/health

# Verify SSL certificate
curl -I https://api.example.com/api/v1/health
# Check for security headers

# Monitor resource usage
pm2 monit
```

---

## 🗄️ DATABASE SETUP

### IMPORTANT: Database Restoration Approach

**⚠️ We use SQL file restoration, NOT Prisma migrations:**

- ✅ Database schema is managed via `lania_sso_postgres.sql` and `lania_common_postgres.sql`
- ✅ `npx prisma generate` is used ONLY to generate TypeScript client
- ❌ `npx prisma migrate` is NEVER used in deployment
- ❌ Manual database creation is handled by SQL files

### Step 1: Create Application User

```bash
# For development/testing
psql -U postgres << EOF
CREATE USER lania_user WITH PASSWORD 'lania_password';
GRANT ALL PRIVILEGES ON DATABASE lania_sso TO lania_user;
GRANT ALL PRIVILEGES ON DATABASE lania_common TO lania_user;
EOF

# For production (remote access)
psql -U postgres -h prod-db-01 << EOF
CREATE USER prod_user WITH PASSWORD 'secure_production_password';
GRANT ALL PRIVILEGES ON DATABASE lania_sso TO prod_user;
GRANT ALL PRIVILEGES ON DATABASE lania_common TO prod_user;
EOF
```

### Step 2: Restore Database from SQL Files

```bash
# Create databases first
psql -U postgres << EOF
CREATE DATABASE lania_sso LOCALE_PROVIDER = 'libc' LOCALE = 'en_US.UTF-8' TEMPLATE template0;
CREATE DATABASE lania_common LOCALE_PROVIDER = 'libc' LOCALE = 'en_US.UTF-8' TEMPLATE template0;
GRANT ALL PRIVILEGES ON DATABASE lania_sso TO lania_user;
GRANT ALL PRIVILEGES ON DATABASE lania_common TO lania_user;
EOF

# Restore lania_sso database
psql -U lania_user -d lania_sso < lania_sso_postgres.sql

# Restore lania_common database
psql -U lania_user -d lania_common < lania_common_postgres.sql

# Verify databases created
psql -U lania_user -d postgres -c "SELECT datname FROM pg_database WHERE datname IN ('lania_sso', 'lania_common');"

# Verify tables (should be 18 tables in lania_sso)
psql -U lania_user -d lania_sso -c "SELECT COUNT(*) as table_count FROM information_schema.tables WHERE table_schema='public' AND table_type='BASE TABLE';"
# Expected: 18 tables

# Verify functions
psql -U lania_user -d lania_sso -c "\df"
# Expected: get_slow_queries, generate_secure_token

# Verify extensions
psql -U lania_user -d lania_sso -c "\dx"
# Expected: uuid-ossp, pg_stat_statements, pgcrypto, pg_trgm
```

### Step 3: Verify Sample Data

```bash
# Sample user is already seeded in SQL files
# Username: superadmin
# Email: syahrulsetiawan72@gmail.com
# Password: password (bcrypt hashed)
# Tenant: Demo Company (demo_company)

# Verify seeded data
psql -U lania_user -d lania_sso -c "SELECT id, name, username, email FROM users LIMIT 5;"

psql -U lania_user -d lania_sso -c "SELECT id, name, code, status FROM tenants LIMIT 5;"
```

### Step 4: Generate Prisma Client

```bash
# Generate Prisma client (TypeScript only, does NOT modify database)
npx prisma generate

# Validate Prisma schema matches database
npx prisma validate

# Expected: ✓ Schema is valid!

# IMPORTANT: Do NOT run "prisma migrate" or "prisma db push"
# Database is already complete from SQL file restoration
```

---

## 🚀 APPLICATION STARTUP

### Development Startup

```bash
# Install dependencies
npm install

# Start development server
npm run start:dev

# Expected output:
# [Nest] 12345 - 11/13/2025 LOG [NestApplication] Listening on 0.0.0.0:8001
```

### Production Startup with PM2

```bash
# Start application
pm2 start ecosystem.config.js

# Verify startup
pm2 list
pm2 logs lania-sso-prod

# Setup auto-start on reboot
pm2 startup
pm2 save
```

### Docker Startup (Optional)

```bash
# Build Docker image
docker build -t laniakea-sso:latest .

# Run container
docker run -d \
  --name lania-sso \
  -p 8001:8001 \
  -e DATABASE_URL="mysql://user:pass@mysql:3306/lania_sso" \
  -e JWT_SECRET="your-secret-key" \
  laniakea-sso:latest

# View logs
docker logs -f lania-sso
```

---

## ✅ VERIFICATION & TESTING

### API Health Check

```bash
# Health endpoint
curl http://localhost:8001/api/v1/health

# Expected response:
# {"status":"ok","timestamp":"2025-11-13T10:30:00Z"}
```

### Authentication Test

```bash
# Login with demo user
curl -X POST http://localhost:8001/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "usernameOrEmail": "superadmin",
    "password": "password",
    "deviceName": "Test Device"
  }'

# Expected response includes:
# {
#   "message": "Login successful",
#   "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
#   "refreshToken": "...",
#   "user": {...}
# }
```

### Get Current User

```bash
# Replace TOKEN with actual token from login
curl -X GET http://localhost:8001/api/v1/auth/me \
  -H "Authorization: Bearer TOKEN"

# Expected response includes:
# {
#   "id": "user-id",
#   "name": "Superadmin Demo",
#   "email": "syahrulsetiawan72@gmail.com",
#   "userConfigs": {...},
#   "tenants": [...]
# }
```

### Database Verification

```bash
# Verify table structure
psql -U lania_user -d lania_sso -c "\d users"
psql -U lania_user -d lania_sso -c "\d sessions"
psql -U lania_user -d lania_sso -c "\d user_configs"

# Verify functions
psql -U lania_user -d lania_sso -c "SELECT * FROM get_slow_queries(1000);"

# Verify extensions
psql -U lania_user -d lania_sso -c "SELECT extname, extversion FROM pg_extension;"
```

---

## 📋 POST-DEPLOYMENT TASKS

### Immediate (First Day)

- [ ] Monitor application logs for errors
- [ ] Monitor database performance
- [ ] Monitor CPU and memory usage
- [ ] Verify all endpoints responding
- [ ] Test email notifications
- [ ] Verify SSL certificate working
- [ ] Confirm backup jobs running

### Within 1 Week

- [ ] Security audit completed
- [ ] Performance baseline established
- [ ] Incident response procedures tested
- [ ] Team trained on monitoring
- [ ] Documentation updated

### Within 1 Month

- [ ] Review and optimize queries
- [ ] Review security logs
- [ ] Update monitoring thresholds
- [ ] Plan database optimization
- [ ] Archive old audit logs

---

## 📊 MONITORING & MAINTENANCE

### Health Checks

```bash
# Check API health every 5 minutes
curl -s http://localhost:8001/api/v1/health | jq .

# Check database connectivity
psql -U lania_user -d lania_sso -c "SELECT NOW();"

# Check PM2 app status
pm2 status
pm2 logs lania-sso-prod --lines 50
```

### Performance Monitoring

```bash
# Monitor CPU and memory with PM2
pm2 monit

# Monitor database with PostgreSQL
psql -U lania_user -d lania_sso -c "SELECT * FROM pg_stat_activity WHERE datname = 'lania_sso';"
psql -U lania_user -d lania_sso -c "SELECT count(*) as active_connections FROM pg_stat_activity WHERE datname = 'lania_sso' AND state = 'active';"
```

### Log Management

```bash
# Logrotate configuration
sudo logrotate -v /etc/logrotate.d/lania-sso

# Manual backup of logs
tar -czf logs-backup-$(date +%Y%m%d).tar.gz logs/

# Stream logs
tail -f logs/output.log
tail -f logs/error.log
```

### Database Maintenance

```bash
# PostgreSQL doesn't require manual cleanup - use pg_cron if needed
# Or implement cleanup via application-level cron jobs

# Vacuum and analyze tables for optimization
psql -U lania_user -d lania_sso -c "VACUUM ANALYZE users, sessions, refresh_tokens, audit_logs;"

# Check table statistics
psql -U lania_user -d lania_sso -c "SELECT schemaname, tablename, n_tup_ins, n_tup_upd, n_tup_del FROM pg_stat_user_tables;"
```

---

## 🆘 TROUBLESHOOTING

### Application Won't Start

```bash
# Check logs
pm2 logs lania-sso-prod

# Verify environment variables
cat .env

# Verify Prisma client generated
npx prisma validate

# Check Node.js version
node --version

# Rebuild
npm run build
```

### Database Connection Issues

```bash
# Test PostgreSQL connection
psql -U lania_user -h 127.0.0.1 -d lania_sso -c "SELECT 1;"

# Verify DATABASE_URL in .env
grep DATABASE_URL .env

# Check PostgreSQL service
sudo systemctl status postgresql

# Restart PostgreSQL if needed
sudo systemctl restart postgresql
```

### High Memory Usage

```bash
# Monitor with PM2
pm2 monit

# Check application logs for memory leaks
pm2 logs lania-sso-prod | grep -i memory

# Restart application
pm2 restart lania-sso-prod

# Check Node.js heap dump
node --inspect --max-old-space-size=2048 dist/main.js
```

### Slow API Responses

```bash
# Check database queries using built-in function
psql -U lania_user -d lania_sso -c "SELECT * FROM get_slow_queries(1000);"

# Monitor Nginx response times
tail -f /var/log/nginx/lania-sso-access.log

# Check application logs
pm2 logs lania-sso-prod

# Profile with Prisma
npx prisma studio
```

### SSL Certificate Issues

```bash
# Verify certificate
openssl x509 -in /etc/letsencrypt/live/api.example.com/fullchain.pem -text -noout

# Test SSL
curl -I https://api.example.com/api/v1/health

# Renew certificate manually
sudo certbot renew --force-renewal
```

---

## 📞 SUPPORT & DOCUMENTATION

- **GitHub**: https://github.com/syahrulsetiawan/lania-sso
- **Issues**: GitHub Issues
- **API Docs**: `/api/v1/docs` (Swagger)
- **Email**: Contact team for production support

---

## ✅ DEPLOYMENT CHECKLIST

Before going live, ensure:

- [ ] All environment variables configured
- [ ] Database backed up
- [ ] SSL certificate installed
- [ ] Nginx configured and tested
- [ ] PM2 process manager configured
- [ ] Application built successfully
- [ ] Health check endpoint responding
- [ ] Authentication working with demo user
- [ ] Database events scheduled
- [ ] Backup jobs configured
- [ ] Monitoring alerts configured
- [ ] Team trained on operations
- [ ] Incident response plan ready
- [ ] Rollback procedure documented

---

**Status**: Ready for Production Deployment ✅  
**Last Updated**: November 13, 2025
