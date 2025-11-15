-- ============================================================================
-- Laniakea Common Database Schema - PostgreSQL
-- ============================================================================
-- Target Server: PostgreSQL 16+ (compatible with 14+)
-- Database: lania_common
--
-- INSTALLED EXTENSIONS:
-- 1. uuid-ossp        - UUID generation (REQUIRED)
-- 2. pg_stat_statements - Query performance monitoring (HIGHLY RECOMMENDED)
-- 3. pgcrypto         - Cryptographic functions (SECURITY)
-- 4. pg_trgm          - Fuzzy search for Indonesian regional data (PERFORMANCE)
--
-- PERFORMANCE FEATURES:
-- - GIN indexes for fast fuzzy search on provinces/regencies/districts/villages
-- - Enables typo-tolerant search for Indonesian place names
-- - Query monitoring for performance optimization
--
-- REQUIREMENTS:
-- - PostgreSQL 16+ or 14+
-- - Enable in postgresql.conf: shared_preload_libraries = 'pg_stat_statements'
--
-- INSTALLATION STEPS:
-- 1. Create database (choose one method):
--    
--    Method A - Using psql command:
--    psql -U postgres -c "CREATE DATABASE lania_common WITH OWNER = postgres ENCODING = 'UTF8' LOCALE_PROVIDER = 'libc' LOCALE = 'en_US.UTF-8';"
--    
--    Method B - Using psql interactive:
--    psql -U postgres
--    CREATE DATABASE lania_common
--        WITH OWNER = postgres
--             ENCODING = 'UTF8'
--             LOCALE_PROVIDER = 'libc'
--             LOCALE = 'en_US.UTF-8';
--    \q
--
-- 2. Import this schema file:
--    psql -U postgres -d lania_common -f lania_common_postgres.sql
--
-- 3. Verify installation:
--    psql -U postgres -d lania_common -c "\dt"
--    psql -U postgres -d lania_common -c "SELECT * FROM default_values;"
--
-- See POSTGRESQL-OPTIMIZATION.md for detailed configuration guide
-- ============================================================================

-- ============================================================================
-- EXTENSIONS (Install FIRST before creating tables/indexes)
-- ============================================================================

-- UUID generation (required)
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Query performance monitoring
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;

-- Cryptographic functions
CREATE EXTENSION IF NOT EXISTS pgcrypto;

-- Trigram similarity for fuzzy search (MUST install before creating GIN indexes)
CREATE EXTENSION IF NOT EXISTS pg_trgm;

-- ============================================================================
-- DEFAULT VALUES (Master Data Seeding)
-- ============================================================================

-- Table: default_values
CREATE TABLE default_values (
    id CHAR(36) PRIMARY KEY,
    table_name VARCHAR(255) NOT NULL,
    insert_values JSONB NOT NULL,
    created_at TIMESTAMP(6),
    updated_at TIMESTAMP(6)
);

CREATE INDEX idx_default_values_table_name ON default_values(table_name);

-- ============================================================================
-- FILE MANAGEMENT
-- ============================================================================

-- Table: file_uploads
CREATE TABLE file_uploads (
    id CHAR(36) PRIMARY KEY,
    tenant_id CHAR(36),
    user_id CHAR(36),
    file_name VARCHAR(255) NOT NULL,
    file_path VARCHAR(2048) NOT NULL,
    file_type VARCHAR(100),
    file_size BIGINT,
    mime_type VARCHAR(255),
    description TEXT,
    is_public BOOLEAN DEFAULT false,
    created_at TIMESTAMP(6),
    updated_at TIMESTAMP(6),
    deleted_at TIMESTAMP(6)
);

CREATE INDEX idx_file_uploads_tenant_id ON file_uploads(tenant_id);
CREATE INDEX idx_file_uploads_user_id ON file_uploads(user_id);
CREATE INDEX idx_file_uploads_deleted_at ON file_uploads(deleted_at);

-- ============================================================================
-- NOTIFICATIONS
-- ============================================================================

-- Table: notifications
CREATE TABLE notifications (
    id CHAR(36) PRIMARY KEY,
    type VARCHAR(255) NOT NULL,
    notifiable_type VARCHAR(255) NOT NULL,
    notifiable_id CHAR(36) NOT NULL,
    data JSONB NOT NULL,
    read_at TIMESTAMP(6),
    created_at TIMESTAMP(6),
    updated_at TIMESTAMP(6)
);

CREATE INDEX idx_notifications_notifiable ON notifications(notifiable_type, notifiable_id);
CREATE INDEX idx_notifications_read_at ON notifications(read_at);
CREATE INDEX idx_notifications_created_at ON notifications(created_at);

-- Table: user_has_notifications
CREATE TABLE user_has_notifications (
    user_id CHAR(36) NOT NULL,
    notification_id CHAR(36) NOT NULL,
    is_read BOOLEAN DEFAULT false,
    read_at TIMESTAMP(6),
    created_at TIMESTAMP(6),
    updated_at TIMESTAMP(6),
    PRIMARY KEY (user_id, notification_id),
    FOREIGN KEY (notification_id) REFERENCES notifications(id) ON DELETE CASCADE
);

CREATE INDEX idx_user_has_notifications_user_id ON user_has_notifications(user_id);
CREATE INDEX idx_user_has_notifications_notification_id ON user_has_notifications(notification_id);

-- ============================================================================
-- INDONESIAN REGIONAL DATA
-- ============================================================================

-- Table: reg_provinces (Provinsi)
CREATE TABLE reg_provinces (
    id CHAR(2) PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP(6),
    updated_at TIMESTAMP(6)
);

CREATE INDEX idx_reg_provinces_name ON reg_provinces(name);

-- GIN index for fuzzy search on province names
CREATE INDEX idx_reg_provinces_name_trgm ON reg_provinces USING GIN (name gin_trgm_ops);

-- Table: reg_regencies (Kabupaten/Kota)
CREATE TABLE reg_regencies (
    id CHAR(4) PRIMARY KEY,
    province_id CHAR(2) NOT NULL,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP(6),
    updated_at TIMESTAMP(6),
    FOREIGN KEY (province_id) REFERENCES reg_provinces(id) ON DELETE CASCADE
);

CREATE INDEX idx_reg_regencies_province_id ON reg_regencies(province_id);
CREATE INDEX idx_reg_regencies_name ON reg_regencies(name);

-- GIN index for fuzzy search on regency names
CREATE INDEX idx_reg_regencies_name_trgm ON reg_regencies USING GIN (name gin_trgm_ops);

-- Table: reg_districts (Kecamatan)
CREATE TABLE reg_districts (
    id CHAR(7) PRIMARY KEY,
    regency_id CHAR(4) NOT NULL,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP(6),
    updated_at TIMESTAMP(6),
    FOREIGN KEY (regency_id) REFERENCES reg_regencies(id) ON DELETE CASCADE
);

CREATE INDEX idx_reg_districts_regency_id ON reg_districts(regency_id);
CREATE INDEX idx_reg_districts_name ON reg_districts(name);

-- GIN index for fuzzy search on district names
CREATE INDEX idx_reg_districts_name_trgm ON reg_districts USING GIN (name gin_trgm_ops);

-- Table: reg_villages (Desa/Kelurahan)
CREATE TABLE reg_villages (
    id CHAR(10) PRIMARY KEY,
    district_id CHAR(7) NOT NULL,
    name VARCHAR(255) NOT NULL,
    created_at TIMESTAMP(6),
    updated_at TIMESTAMP(6),
    FOREIGN KEY (district_id) REFERENCES reg_districts(id) ON DELETE CASCADE
);

CREATE INDEX idx_reg_villages_district_id ON reg_villages(district_id);
CREATE INDEX idx_reg_villages_name ON reg_villages(name);

-- GIN index for fuzzy search on village names
CREATE INDEX idx_reg_villages_name_trgm ON reg_villages USING GIN (name gin_trgm_ops);

-- ============================================================================
-- DATA IMPORT NOTES
-- ============================================================================

-- NOTE: The original MySQL dump contains ~91,000 lines of INSERT statements
-- for Indonesian regional data (provinces, regencies, districts, villages).
-- 
-- To import this data into PostgreSQL:
-- 1. Export data from MySQL using:
--    mysqldump -u root -p lania_common default_values file_uploads notifications \
--    user_has_notifications reg_provinces reg_regencies reg_districts reg_villages \
--    --no-create-info --complete-insert > lania_common_data.sql
--
-- 2. Convert MySQL syntax to PostgreSQL:
--    - Replace backticks with double quotes or remove them
--    - Convert INSERT statements format
--    - Handle JSON data type differences
--
-- 3. Or use a migration tool like pgLoader:
--    pgloader mysql://user:pass@localhost/lania_common \
--             postgresql://postgres:pass@localhost/lania_common
--
-- 4. Or import directly from the application using Prisma:
--    - Keep data in MySQL temporarily
--    - Use application code to migrate data incrementally
--
-- For development/testing, you can start with empty tables and populate
-- only the essential default_values needed for your application to work.

-- ============================================================================
-- ESSENTIAL SEED DATA (Minimal for Development)
-- ============================================================================

-- Insert essential default_values for states
INSERT INTO default_values (id, table_name, insert_values, created_at, updated_at) VALUES
('41e22e2a-f63b-476a-9743-010e6f5aed61', 'states', '{"key":"draft","name":"Draft","description":"Initial state of the document.","color":"grey","icon":"draft-icon.png","can_edit":true,"can_delete":true,"can_print":false,"is_active":true,"is_default":true}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('32f2da79-e378-47fc-a0f9-881f6b9f1bbf', 'states', '{"key":"submitted","name":"Submitted","description":"Document has been submitted for review.","color":"blue","icon":"submitted-icon.png","can_edit":false,"can_delete":false,"can_print":true,"is_active":true,"is_default":true}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('7aa6d179-2c4e-49d7-a1f9-542627d44d1d', 'states', '{"key":"approved","name":"Approved","description":"Document has been approved.","color":"green","icon":"approved-icon.png","can_edit":false,"can_delete":false,"can_print":true,"is_active":true,"is_default":true}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('03289ce5-df6d-4b6f-b453-91ad212a58c7', 'states', '{"key":"rejected","name":"Rejected","description":"Document has been rejected.","color":"red","icon":"rejected-icon.png","can_edit":false,"can_delete":false,"can_print":false,"is_active":true,"is_default":true}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Insert essential modules
INSERT INTO default_values (id, table_name, insert_values, created_at, updated_at) VALUES
('8eefae79-7a5b-4ffa-a7c4-9e35d4989d49', 'modules', '{"key":"chart-of-account","name":"Chart of Account","service_key":"accounting","group":"accounting","default_prefix_code":"COA","is_active":true,"has_workflow":false,"can_be_deleted":false}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('456b21cf-bd72-4231-98bb-aae10e3e5a76', 'modules', '{"key":"journal-entry","name":"Journal Entry","service_key":"accounting","group":"accounting","default_prefix_code":"JRN","is_active":true,"has_workflow":true,"can_be_deleted":false}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Insert essential tenant configs
INSERT INTO default_values (id, table_name, insert_values, created_at, updated_at) VALUES
('27121362-b2ee-4b43-8ed6-ee65120ada89', 'tenant_configs', '{"config_key":"timezone","config_value":"Asia/Jakarta","config_type":"select"}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('0e4a1905-8d49-4671-9690-e8d09ec28824', 'tenant_configs', '{"config_key":"date_format","config_value":"Y-m-d","config_type":"select"}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('1a410dfb-e498-478d-997d-3eb623cb3e8b', 'tenant_configs', '{"config_key":"currency_format","config_value":"Rp #,##0","config_type":"select"}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- Insert essential user configs
INSERT INTO default_values (id, table_name, insert_values, created_at, updated_at) VALUES
('5e7607c6-13c6-4c02-9004-2aeab9243699', 'user_configs', '{"config_key":"language","config_value":"id","config_type":"string"}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP),
('93d54f2e-4908-4026-b250-593a4aa90fb5', 'user_configs', '{"config_key":"menu_layout","config_value":"vertical","config_type":"string"}', CURRENT_TIMESTAMP, CURRENT_TIMESTAMP);

-- ============================================================================
-- GRANTS & PERMISSIONS
-- ============================================================================
-- Grant permissions to application user (create this user separately)
-- CREATE USER lania_user WITH PASSWORD 'your_password';
-- GRANT CONNECT ON DATABASE lania_common TO lania_user;
-- GRANT USAGE ON SCHEMA public TO lania_user;
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO lania_user;
-- GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO lania_user;
