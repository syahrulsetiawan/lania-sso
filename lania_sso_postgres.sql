-- ============================================================================
-- Laniakea SSO Database Schema - PostgreSQL
-- ============================================================================
-- Target Server: PostgreSQL 16+ (compatible with 14+)
-- Database: lania_sso
--
-- INSTALLED EXTENSIONS:
-- 1. uuid-ossp        - UUID generation (REQUIRED) ✅
-- 2. pg_stat_statements - Query performance monitoring (HIGHLY RECOMMENDED) ✅
-- 3. pgcrypto         - Secure token generation & encryption (SECURITY) ✅
-- 4. pg_trgm          - Fuzzy search with typo tolerance (PERFORMANCE) ✅
-- 5. pg_cron          - Automated cleanup tasks (OPTIONAL - NOT AUTO-INSTALLED) ⚠️
--
-- NOTE: pg_cron is NOT included in standard PostgreSQL installation!
-- Windows: Download from https://github.com/citusdata/pg_cron/releases
-- Linux: apt install postgresql-17-cron (Ubuntu/Debian)
-- macOS: brew install pg_cron
-- After installation, see "SCHEDULED JOBS" section at end of this file
--
-- PERFORMANCE FEATURES:
-- - GIN indexes for fast fuzzy text search on users/tenants
-- - Utility functions for monitoring and token generation
-- - Automated cleanup schedules (requires pg_cron)
--
-- REQUIREMENTS:
-- - PostgreSQL 16+ or 14+
-- - Enable in postgresql.conf: shared_preload_libraries = 'pg_stat_statements'
-- - Optional: Install pg_cron for automated maintenance
--
-- INSTALLATION STEPS:
-- 1. Create database (choose one method):
--    
--    Method A - Using psql command:
--    psql -U postgres -c "CREATE DATABASE lania_sso WITH OWNER = postgres ENCODING = 'UTF8' LOCALE_PROVIDER = 'libc' LOCALE = 'en_US.UTF-8';"
--    
--    Method B - Using psql interactive:
--    psql -U postgres
--    CREATE DATABASE lania_sso
--        WITH OWNER = postgres
--             ENCODING = 'UTF8'
--             LOCALE_PROVIDER = 'libc'
--             LOCALE = 'en_US.UTF-8';
--    \q
--
-- 2. Import this schema file:
--    psql -U postgres -d lania_sso -f lania_sso_postgres.sql
--
-- 3. Verify installation:
--    psql -U postgres -d lania_sso -c "\dt"
--    psql -U postgres -d lania_sso -c "SELECT * FROM core_services;"
--
-- See POSTGRESQL-OPTIMIZATION.md for detailed configuration guide
-- ============================================================================

-- ============================================================================
-- EXTENSIONS (Install FIRST before creating tables/indexes)
-- ============================================================================

-- UUID generation (required for CHAR(36) ID columns)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Query performance monitoring
-- Enable in postgresql.conf: shared_preload_libraries = 'pg_stat_statements'
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- Cryptographic functions for secure token generation
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Trigram similarity for fuzzy search (MUST install before creating GIN indexes)
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- ============================================================================
-- CORE MASTER DATA
-- ============================================================================

-- Table: core_licenses
CREATE TABLE core_licenses (
    key VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description VARCHAR(255),
    default_value VARCHAR(255),
    created_at TIMESTAMP(6),
    updated_at TIMESTAMP(6)
);

-- Table: core_services
CREATE TABLE core_services (
    key VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    icon VARCHAR(255),
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMP(6),
    updated_at TIMESTAMP(6)
);

-- Table: core_status_tenants
CREATE TABLE core_status_tenants (
    key VARCHAR(255) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description VARCHAR(255),
    created_at TIMESTAMP(6),
    updated_at TIMESTAMP(6)
);

-- ============================================================================
-- USER MANAGEMENT
-- ============================================================================

-- Table: users
CREATE TABLE users (
    id CHAR(36) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    username VARCHAR(50) UNIQUE NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    profile_photo_path VARCHAR(2048),
    last_tenant_id CHAR(36),
    last_service_key VARCHAR(255),
    email_verified_at TIMESTAMP(6),
    failed_login_counter INTEGER DEFAULT 0,
    temporary_lock_until TIMESTAMP(6),
    is_locked BOOLEAN DEFAULT false,
    locked_at TIMESTAMP(6),
    force_logout_at TIMESTAMP(6),
    remember_token VARCHAR(255),
    last_login_at TIMESTAMP(6),
    last_login_ip VARCHAR(45),
    created_at TIMESTAMP(6),
    updated_at TIMESTAMP(6),
    deleted_at TIMESTAMP(6)
);

CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_deleted_at ON users(deleted_at);

-- GIN indexes for fuzzy/full-text search using pg_trgm
CREATE INDEX idx_users_name_trgm ON users USING GIN (name gin_trgm_ops);
CREATE INDEX idx_users_email_trgm ON users USING GIN (email gin_trgm_ops);

-- Table: sessions
CREATE TABLE sessions (
    id CHAR(36) PRIMARY KEY,
    user_id CHAR(36) NOT NULL,
    ip_address VARCHAR(45),
    user_agent VARCHAR(255),
    device_name VARCHAR(100),
    latitude VARCHAR(50),
    longitude VARCHAR(50),
    payload TEXT,
    last_activity TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    revoked_at TIMESTAMP(6),
    created_at TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_sessions_user_id ON sessions(user_id);
CREATE INDEX idx_sessions_revoked_at ON sessions(revoked_at);
CREATE INDEX idx_sessions_last_activity ON sessions(last_activity);

-- Table: refresh_tokens
CREATE TABLE refresh_tokens (
    id CHAR(36) PRIMARY KEY,
    user_id CHAR(36) NOT NULL,
    session_id CHAR(36) NOT NULL,
    token_hash VARCHAR(128) UNIQUE NOT NULL,
    expires_at TIMESTAMP(6) NOT NULL,
    revoked BOOLEAN DEFAULT false,
    revoked_at TIMESTAMP(6),
    created_at TIMESTAMP(6),
    updated_at TIMESTAMP(6),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (session_id) REFERENCES sessions(id) ON DELETE CASCADE
);

CREATE INDEX idx_refresh_tokens_user_id ON refresh_tokens(user_id);
CREATE INDEX idx_refresh_tokens_session_id ON refresh_tokens(session_id);
CREATE INDEX idx_refresh_tokens_token_hash ON refresh_tokens(token_hash);
CREATE INDEX idx_refresh_tokens_expires_at ON refresh_tokens(expires_at);

-- Table: password_reset_tokens
CREATE TABLE password_reset_tokens (
    email VARCHAR(255) PRIMARY KEY,
    token VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP(6) NOT NULL,
    created_at TIMESTAMP(6)
);

CREATE INDEX idx_password_reset_tokens_token ON password_reset_tokens(token);

-- Table: email_verification_tokens
CREATE TABLE email_verification_tokens (
    email VARCHAR(255) PRIMARY KEY,
    token VARCHAR(255) NOT NULL,
    expires_at TIMESTAMP(6) NOT NULL,
    created_at TIMESTAMP(6)
);

CREATE INDEX idx_email_verification_tokens_token ON email_verification_tokens(token);

-- Table: failed_login_attempts
CREATE TABLE failed_login_attempts (
    id CHAR(36) PRIMARY KEY,
    user_id CHAR(36),
    ip_address VARCHAR(45),
    user_agent VARCHAR(255),
    payload TEXT,
    attempted_at TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    latitude VARCHAR(255),
    longitude VARCHAR(255),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

CREATE INDEX idx_failed_login_attempts_user_id ON failed_login_attempts(user_id);
CREATE INDEX idx_failed_login_attempts_ip_address ON failed_login_attempts(ip_address);
CREATE INDEX idx_failed_login_attempts_attempted_at ON failed_login_attempts(attempted_at);

-- ============================================================================
-- TENANT MANAGEMENT
-- ============================================================================

-- Table: tenants
CREATE TABLE tenants (
    id CHAR(36) PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    code VARCHAR(20) UNIQUE NOT NULL,
    logo_path VARCHAR(2048),
    info_website VARCHAR(255),
    info_email VARCHAR(255),
    info_phone VARCHAR(255),
    info_tax_number VARCHAR(255),
    address VARCHAR(255),
    country VARCHAR(100),
    province VARCHAR(100),
    city VARCHAR(100),
    postal_code VARCHAR(20),
    is_active BOOLEAN DEFAULT true,
    status VARCHAR(255) DEFAULT 'trial',
    joined_at TIMESTAMP(6) DEFAULT CURRENT_TIMESTAMP,
    expired_at TIMESTAMP(6),
    revoked_at TIMESTAMP(6),
    maximal_failed_login_attempts INTEGER DEFAULT 5,
    created_at TIMESTAMP(6),
    updated_at TIMESTAMP(6),
    deleted_at TIMESTAMP(6)
);

CREATE INDEX idx_tenants_code ON tenants(code);
CREATE INDEX idx_tenants_status ON tenants(status);

-- GIN index for fuzzy search on tenant names
CREATE INDEX idx_tenants_name_trgm ON tenants USING GIN (name gin_trgm_ops);

-- Table: tenant_has_user
CREATE TABLE tenant_has_user (
    tenant_id CHAR(36) NOT NULL,
    user_id CHAR(36) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    is_owner BOOLEAN DEFAULT false,
    created_at TIMESTAMP(6),
    updated_at TIMESTAMP(6),
    PRIMARY KEY (tenant_id, user_id),
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

CREATE INDEX idx_tenant_has_user_tenant_id ON tenant_has_user(tenant_id);
CREATE INDEX idx_tenant_has_user_user_id ON tenant_has_user(user_id);

-- Table: tenant_configs
CREATE TABLE tenant_configs (
    id CHAR(36) PRIMARY KEY,
    tenant_id CHAR(36) NOT NULL,
    config_key VARCHAR(255) NOT NULL,
    config_value TEXT,
    config_type VARCHAR(50) DEFAULT 'string',
    created_at TIMESTAMP(6),
    updated_at TIMESTAMP(6),
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    UNIQUE(tenant_id, config_key)
);

CREATE INDEX idx_tenant_configs_tenant_id ON tenant_configs(tenant_id);
CREATE INDEX idx_tenant_configs_config_key ON tenant_configs(config_key);

-- Table: tenant_connections
CREATE TABLE tenant_connections (
    id CHAR(36) PRIMARY KEY,
    tenant_id CHAR(36) NOT NULL,
    database_name VARCHAR(255) NOT NULL,
    database_host VARCHAR(255) NOT NULL,
    database_port INTEGER NOT NULL,
    database_username VARCHAR(255) NOT NULL,
    database_password VARCHAR(255) NOT NULL,
    created_at TIMESTAMP(6),
    updated_at TIMESTAMP(6),
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE
);

CREATE INDEX idx_tenant_connections_tenant_id ON tenant_connections(tenant_id);

-- Table: tenant_licenses
CREATE TABLE tenant_licenses (
    id CHAR(36) PRIMARY KEY,
    tenant_id CHAR(36) NOT NULL,
    license_key VARCHAR(255) NOT NULL,
    license_value TEXT,
    created_at TIMESTAMP(6),
    updated_at TIMESTAMP(6),
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    FOREIGN KEY (license_key) REFERENCES core_licenses(key) ON DELETE CASCADE
);

CREATE INDEX idx_tenant_licenses_tenant_id ON tenant_licenses(tenant_id);
CREATE INDEX idx_tenant_licenses_license_key ON tenant_licenses(license_key);

-- Table: tenant_has_service
CREATE TABLE tenant_has_service (
    id CHAR(36) PRIMARY KEY,
    tenant_id CHAR(36) NOT NULL,
    service_key VARCHAR(255) NOT NULL,
    is_active BOOLEAN DEFAULT true,
    expired_at TIMESTAMP(6),
    created_at TIMESTAMP(6),
    updated_at TIMESTAMP(6),
    FOREIGN KEY (tenant_id) REFERENCES tenants(id) ON DELETE CASCADE,
    FOREIGN KEY (service_key) REFERENCES core_services(key) ON DELETE CASCADE,
    UNIQUE(tenant_id, service_key)
);

CREATE INDEX idx_tenant_has_service_tenant_id ON tenant_has_service(tenant_id);
CREATE INDEX idx_tenant_has_service_service_key ON tenant_has_service(service_key);

-- ============================================================================
-- USER CONFIGURATION
-- ============================================================================

-- Table: user_configs
CREATE TABLE user_configs (
    id CHAR(36) PRIMARY KEY,
    user_id CHAR(36) NOT NULL,
    config_key VARCHAR(255) NOT NULL,
    config_value TEXT,
    created_at TIMESTAMP(6),
    updated_at TIMESTAMP(6),
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    UNIQUE(user_id, config_key)
);

CREATE INDEX idx_user_configs_user_id ON user_configs(user_id);
CREATE INDEX idx_user_configs_config_key ON user_configs(config_key);

-- ============================================================================
-- AUDIT LOGS
-- ============================================================================

-- Table: audit_logs
CREATE TABLE audit_logs (
    id CHAR(36) PRIMARY KEY,
    user_type VARCHAR(255),
    user_id VARCHAR(255),
    event VARCHAR(255) NOT NULL,
    auditable_table VARCHAR(255) NOT NULL,
    auditable_id CHAR(36) NOT NULL,
    old_values TEXT,
    new_values TEXT,
    url TEXT,
    payload JSONB,
    ip_address VARCHAR(45),
    user_agent VARCHAR(255),
    tags VARCHAR(255),
    created_at TIMESTAMP(6),
    updated_at TIMESTAMP(6)
);

CREATE INDEX idx_audit_logs_auditable_table_id ON audit_logs(auditable_table, auditable_id);
CREATE INDEX idx_audit_logs_user_id_type ON audit_logs(user_id, user_type);
CREATE INDEX idx_audit_logs_user_id ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_auditable_table ON audit_logs(auditable_table);
CREATE INDEX idx_audit_logs_auditable_id ON audit_logs(auditable_id);
CREATE INDEX idx_audit_logs_event ON audit_logs(event);
CREATE INDEX idx_audit_logs_user_type ON audit_logs(user_type);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);
CREATE INDEX idx_audit_logs_table_created ON audit_logs(auditable_table, created_at);
CREATE INDEX idx_audit_logs_user_event_created ON audit_logs(user_id, event, created_at);

-- ============================================================================
-- SEED DATA
-- ============================================================================

-- Insert core services
INSERT INTO core_services (key, name, description, icon, is_active, created_at, updated_at) VALUES
('erp', 'ERP', 'Enterprise Resource Planning', 'mdi-factory', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('accounting', 'Accounting', 'Accounting & Finance Management', 'mdi-calculator', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('pos', 'POS', 'Point of Sale System', 'mdi-cash-register', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('hrm', 'HRM', 'Human Resource Management', 'mdi-account-group', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('inventory', 'Inventory', 'Warehouse & Inventory Management', 'mdi-warehouse', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Insert core licenses
INSERT INTO core_licenses (key, name, description, default_value, created_at, updated_at) VALUES
('max_users', 'Maximum Users', 'Maximum number of users allowed', '10', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('max_branches', 'Maximum Branches', 'Maximum number of branches allowed', '1', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('max_warehouses', 'Maximum Warehouses', 'Maximum number of warehouses allowed', '1', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Insert core status tenants
INSERT INTO core_status_tenants (key, name, description, created_at, updated_at) VALUES
('trial', 'Trial', 'Trial period', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('active', 'Active', 'Active subscription', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('expired', 'Expired', 'Subscription expired', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('suspended', 'Suspended', 'Account suspended', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Insert demo tenant
INSERT INTO tenants (id, name, code, status, is_active, created_at, updated_at) VALUES
('550e8400-e29b-41d4-a716-446655440000', 'Demo Company', 'demo', 'trial', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Insert demo user (password: password)
INSERT INTO users (id, name, username, email, password, email_verified_at, created_at, updated_at, last_tenant_id) VALUES
('790de8f0-0574-4d28-bd62-d04d4a85b793', 'Super Admin', 'superadmin', 'syahrulsetiawan72@gmail.com', 
'$2a$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, 
'550e8400-e29b-41d4-a716-446655440000');

-- Link user to tenant
INSERT INTO tenant_has_user (tenant_id, user_id, is_active, is_owner, created_at, updated_at) VALUES
('550e8400-e29b-41d4-a716-446655440000', '790de8f0-0574-4d28-bd62-d04d4a85b793', true, true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Add services to tenant
INSERT INTO tenant_has_service (id, tenant_id, service_key, is_active, created_at, updated_at) VALUES
(uuid_generate_v4()::text, '550e8400-e29b-41d4-a716-446655440000', 'erp', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
(uuid_generate_v4()::text, '550e8400-e29b-41d4-a716-446655440000', 'accounting', true, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- ============================================================================
-- STORED PROCEDURES & FUNCTIONS
-- ============================================================================

-- Function to cleanup old audit logs (older than 3 months)
CREATE OR REPLACE FUNCTION cleanup_old_audit_logs()
RETURNS void AS $$
BEGIN
    DELETE FROM audit_logs 
    WHERE created_at < CURRENT_TIMESTAMP - INTERVAL '3 months';
END;
$$ LANGUAGE plpgsql;

-- Function to cleanup expired tokens and sessions
CREATE OR REPLACE FUNCTION cleanup_expired_tokens_and_sessions()
RETURNS void AS $$
BEGIN
    -- Delete expired password reset tokens
    DELETE FROM password_reset_tokens 
    WHERE expires_at < CURRENT_TIMESTAMP;
    
    -- Delete expired email verification tokens
    DELETE FROM email_verification_tokens 
    WHERE expires_at < CURRENT_TIMESTAMP;
    
    -- Delete expired refresh tokens
    DELETE FROM refresh_tokens 
    WHERE expires_at < CURRENT_TIMESTAMP;
    
    -- Delete old revoked sessions (older than 30 days)
    DELETE FROM sessions 
    WHERE revoked_at IS NOT NULL 
    AND revoked_at < CURRENT_TIMESTAMP - INTERVAL '30 days';
    
    -- Delete old failed login attempts (older than 90 days)
    DELETE FROM failed_login_attempts 
    WHERE attempted_at < CURRENT_TIMESTAMP - INTERVAL '90 days';
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- UTILITY FUNCTIONS
-- ============================================================================

-- Function to get query performance statistics
CREATE OR REPLACE FUNCTION get_slow_queries(min_duration_ms INTEGER DEFAULT 1000)
RETURNS TABLE (
    query TEXT,
    calls BIGINT,
    total_time_ms NUMERIC,
    mean_time_ms NUMERIC,
    max_time_ms NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        query::TEXT,
        calls,
        (total_exec_time)::NUMERIC as total_time_ms,
        (mean_exec_time)::NUMERIC as mean_time_ms,
        (max_exec_time)::NUMERIC as max_time_ms
    FROM pg_stat_statements
    WHERE mean_exec_time > min_duration_ms
    ORDER BY mean_exec_time DESC
    LIMIT 20;
END;
$$ LANGUAGE plpgsql;

-- Function to generate secure tokens using pgcrypto
CREATE OR REPLACE FUNCTION generate_secure_token(length INTEGER DEFAULT 32)
RETURNS TEXT AS $$
BEGIN
    RETURN encode(gen_random_bytes(length), 'hex');
END;
$$ LANGUAGE plpgsql;

-- ============================================================================
-- SCHEDULED JOBS (Using pg_cron extension - install separately)
-- ============================================================================
-- Note: pg_cron needs to be installed separately and enabled in postgresql.conf
-- Installation: apt install postgresql-16-cron (Ubuntu/Debian)
-- Config: shared_preload_libraries = 'pg_stat_statements,pg_cron'
--         cron.database_name = 'lania_sso'
--
-- Uncomment after installing pg_cron:
--
-- -- Daily cleanup expired tokens at 2:00 AM
-- SELECT cron.schedule('cleanup-expired-tokens', '0 2 * * *', $$
--   DELETE FROM refresh_tokens WHERE expires_at < NOW();
--   DELETE FROM password_reset_tokens WHERE expires_at < NOW();
--   DELETE FROM email_verification_tokens WHERE expires_at < NOW();
-- $$);
--
-- -- Monthly cleanup old audit logs (1st of month at 3:00 AM)
-- SELECT cron.schedule('cleanup-audit-logs', '0 3 1 * *', $$
--   SELECT cleanup_old_audit_logs();
-- $$);
--
-- -- Daily cleanup expired tokens and old sessions at 2:30 AM
-- SELECT cron.schedule('cleanup-expired-data', '30 2 * * *', $$
--   SELECT cleanup_expired_tokens_and_sessions();
-- $$);
--
-- -- Weekly cleanup old failed login attempts (Sunday at 3:00 AM)
-- SELECT cron.schedule('cleanup-failed-logins', '0 3 * * 0', $$
--   DELETE FROM failed_login_attempts WHERE attempted_at < NOW() - INTERVAL '90 days';
-- $$);
--
-- -- View scheduled jobs
-- SELECT * FROM cron.job;
--
-- -- View job run history
-- SELECT * FROM cron.job_run_details ORDER BY start_time DESC LIMIT 10;

-- ============================================================================
-- GRANTS & PERMISSIONS
-- ============================================================================
-- Grant permissions to application user (create this user separately)
-- CREATE USER lania_user WITH PASSWORD 'your_password';
-- GRANT CONNECT ON DATABASE lania_sso TO lania_user;
-- GRANT USAGE ON SCHEMA public TO lania_user;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO lania_user;
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO lania_user;
