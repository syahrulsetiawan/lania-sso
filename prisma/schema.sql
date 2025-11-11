-- ============================================================================
-- Laniakea SSO Database Schema
-- MySQL 8.0+
-- Manual Schema Creation (No Prisma Migrations)
-- ============================================================================

-- Create database if not exists
CREATE DATABASE IF NOT EXISTS lania_sso CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE lania_sso;

-- ============================================================================
-- USER MANAGEMENT
-- ============================================================================

-- Users table
CREATE TABLE IF NOT EXISTS `users` (
  `id` VARCHAR(36) PRIMARY KEY,
  `email` VARCHAR(255) NOT NULL UNIQUE,
  `username` VARCHAR(100) NOT NULL UNIQUE,
  `password` VARCHAR(255) NOT NULL COMMENT 'bcrypt hash',
  `full_name` VARCHAR(255) NOT NULL,
  `is_active` BOOLEAN NOT NULL DEFAULT TRUE,
  `is_verified` BOOLEAN NOT NULL DEFAULT FALSE,
  `created_at` DATETIME(0) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME(0) NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  `last_login_at` DATETIME(0) NULL,
  INDEX `idx_users_email` (`email`),
  INDEX `idx_users_username` (`username`),
  INDEX `idx_users_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='User account table - Stores core user information';

-- User profiles table
CREATE TABLE IF NOT EXISTS `user_profiles` (
  `id` VARCHAR(36) PRIMARY KEY,
  `user_id` VARCHAR(36) NOT NULL UNIQUE,
  `phone` VARCHAR(20) NULL,
  `avatar` VARCHAR(500) NULL,
  `bio` TEXT NULL,
  `timezone` VARCHAR(50) NOT NULL DEFAULT 'Asia/Jakarta',
  `locale` VARCHAR(10) NOT NULL DEFAULT 'id-ID',
  `metadata` JSON NULL COMMENT 'Additional user metadata in JSON format',
  `created_at` DATETIME(0) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME(0) NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_user_profiles_user_id` (`user_id`),
  CONSTRAINT `fk_user_profiles_user_id` 
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) 
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Extended user profile information';

-- ============================================================================
-- AUTHENTICATION & SESSION MANAGEMENT
-- ============================================================================

-- Sessions table
CREATE TABLE IF NOT EXISTS `sessions` (
  `id` VARCHAR(36) PRIMARY KEY,
  `user_id` VARCHAR(36) NOT NULL,
  `token` VARCHAR(500) NOT NULL UNIQUE COMMENT 'JWT access token hash',
  `ip_address` VARCHAR(45) NOT NULL COMMENT 'IPv4 or IPv6 address',
  `user_agent` VARCHAR(500) NOT NULL,
  `is_active` BOOLEAN NOT NULL DEFAULT TRUE,
  `device_type` VARCHAR(50) NULL,
  `browser` VARCHAR(100) NULL,
  `os` VARCHAR(100) NULL,
  `created_at` DATETIME(0) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at` DATETIME(0) NOT NULL,
  `last_activity_at` DATETIME(0) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  INDEX `idx_sessions_user_id` (`user_id`),
  INDEX `idx_sessions_token` (`token`),
  INDEX `idx_sessions_is_active` (`is_active`),
  INDEX `idx_sessions_expires_at` (`expires_at`),
  CONSTRAINT `fk_sessions_user_id` 
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) 
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Active user sessions for security monitoring';

-- Refresh tokens table
CREATE TABLE IF NOT EXISTS `refresh_tokens` (
  `id` VARCHAR(36) PRIMARY KEY,
  `user_id` VARCHAR(36) NOT NULL,
  `token` VARCHAR(500) NOT NULL UNIQUE COMMENT 'Hashed refresh token',
  `is_revoked` BOOLEAN NOT NULL DEFAULT FALSE,
  `ip_address` VARCHAR(45) NOT NULL,
  `user_agent` VARCHAR(500) NOT NULL,
  `created_at` DATETIME(0) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expires_at` DATETIME(0) NOT NULL,
  `revoked_at` DATETIME(0) NULL,
  INDEX `idx_refresh_tokens_user_id` (`user_id`),
  INDEX `idx_refresh_tokens_token` (`token`),
  INDEX `idx_refresh_tokens_is_revoked` (`is_revoked`),
  INDEX `idx_refresh_tokens_expires_at` (`expires_at`),
  CONSTRAINT `fk_refresh_tokens_user_id` 
    FOREIGN KEY (`user_id`) REFERENCES `users`(`id`) 
    ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Refresh tokens for secure token rotation';

-- ============================================================================
-- AUDIT TRAIL
-- ============================================================================

-- Audit logs table
CREATE TABLE IF NOT EXISTS `audit_logs` (
  `id` CHAR(36) PRIMARY KEY,
  `user_type` VARCHAR(255) NOT NULL COMMENT 'Type of user (e.g., User, Admin, System)',
  `user_id` VARCHAR(255) NOT NULL COMMENT 'User identifier',
  `event` VARCHAR(255) NOT NULL COMMENT 'Event name (e.g., created, updated, deleted)',
  `auditable_table` VARCHAR(255) NOT NULL COMMENT 'Table name being audited',
  `auditable_id` CHAR(36) NOT NULL COMMENT 'ID of the record being audited',
  `old_values` TEXT NULL COMMENT 'JSON string of old values before change',
  `new_values` TEXT NULL COMMENT 'JSON string of new values after change',
  `url` TEXT NOT NULL COMMENT 'Request URL',
  `payload` JSON NULL COMMENT 'Request payload in JSON format',
  `ip_address` VARCHAR(45) NOT NULL COMMENT 'IPv4 or IPv6 address',
  `user_agent` VARCHAR(255) NOT NULL COMMENT 'Browser user agent',
  `tags` VARCHAR(255) NULL COMMENT 'Comma-separated tags for filtering',
  `created_at` TIMESTAMP(0) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` TIMESTAMP(0) NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_audit_logs_user_id` (`user_id`),
  INDEX `idx_audit_logs_auditable_table` (`auditable_table`),
  INDEX `idx_audit_logs_auditable_id` (`auditable_id`),
  INDEX `idx_audit_logs_event` (`event`),
  INDEX `idx_audit_logs_user_type` (`user_type`),
  INDEX `idx_audit_logs_created_at` (`created_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='Comprehensive audit trail for all system operations';

-- ============================================================================
-- SYSTEM CONFIGURATION
-- ============================================================================

-- System configs table
CREATE TABLE IF NOT EXISTS `system_configs` (
  `id` VARCHAR(36) PRIMARY KEY,
  `key` VARCHAR(100) NOT NULL UNIQUE,
  `value` TEXT NOT NULL,
  `description` VARCHAR(500) NULL,
  `category` VARCHAR(50) NOT NULL COMMENT 'e.g., security, email, general',
  `is_encrypted` BOOLEAN NOT NULL DEFAULT FALSE,
  `created_at` DATETIME(0) NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` DATETIME(0) NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  INDEX `idx_system_configs_key` (`key`),
  INDEX `idx_system_configs_category` (`category`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci
COMMENT='System settings and configurations';

-- ============================================================================
-- SAMPLE DATA (Optional - for testing)
-- ============================================================================

-- Insert sample user (password: "Password123!")
-- Bcrypt hash generated with cost factor 10
INSERT INTO `users` (`id`, `email`, `username`, `password`, `full_name`, `is_active`, `is_verified`, `created_at`, `updated_at`)
VALUES (
  UUID(),
  'admin@laniakea.com',
  'admin',
  '$2a$10$YourBcryptHashHere', -- Replace with actual bcrypt hash
  'System Administrator',
  TRUE,
  TRUE,
  NOW(),
  NOW()
) ON DUPLICATE KEY UPDATE `email` = `email`;

-- Insert sample system configs
INSERT INTO `system_configs` (`id`, `key`, `value`, `description`, `category`, `created_at`, `updated_at`)
VALUES 
  (UUID(), 'app.name', 'Laniakea SSO', 'Application name', 'general', NOW(), NOW()),
  (UUID(), 'app.version', '1.0.0', 'Application version', 'general', NOW(), NOW()),
  (UUID(), 'security.session_timeout', '3600', 'Session timeout in seconds', 'security', NOW(), NOW()),
  (UUID(), 'security.max_login_attempts', '5', 'Maximum login attempts before lockout', 'security', NOW(), NOW())
ON DUPLICATE KEY UPDATE `key` = `key`;

-- ============================================================================
-- VIEWS (Optional - for reporting)
-- ============================================================================

-- Active sessions view
CREATE OR REPLACE VIEW `v_active_sessions` AS
SELECT 
  s.id,
  s.user_id,
  u.email,
  u.username,
  s.ip_address,
  s.device_type,
  s.browser,
  s.os,
  s.created_at,
  s.expires_at,
  s.last_activity_at
FROM sessions s
INNER JOIN users u ON s.user_id = u.id
WHERE s.is_active = TRUE 
  AND s.expires_at > NOW();

-- Recent audit logs view
CREATE OR REPLACE VIEW `v_recent_audit_logs` AS
SELECT 
  al.id,
  al.user_type,
  al.user_id,
  al.event,
  al.auditable_table,
  al.auditable_id,
  al.url,
  al.ip_address,
  al.tags,
  al.created_at
FROM audit_logs al
ORDER BY al.created_at DESC
LIMIT 1000;

-- ============================================================================
-- STORED PROCEDURES (Optional - for common operations)
-- ============================================================================

DELIMITER //

-- Procedure to cleanup expired sessions
CREATE PROCEDURE `sp_cleanup_expired_sessions`()
BEGIN
  DELETE FROM sessions 
  WHERE expires_at < NOW() 
    OR (is_active = FALSE AND created_at < DATE_SUB(NOW(), INTERVAL 7 DAY));
  
  SELECT ROW_COUNT() as deleted_count;
END//

-- Procedure to cleanup expired refresh tokens
CREATE PROCEDURE `sp_cleanup_expired_refresh_tokens`()
BEGIN
  DELETE FROM refresh_tokens 
  WHERE expires_at < NOW() 
    OR (is_revoked = TRUE AND created_at < DATE_SUB(NOW(), INTERVAL 30 DAY));
  
  SELECT ROW_COUNT() as deleted_count;
END//

-- Procedure to get user session statistics
CREATE PROCEDURE `sp_get_user_session_stats`(IN p_user_id VARCHAR(36))
BEGIN
  SELECT 
    COUNT(*) as total_sessions,
    SUM(CASE WHEN is_active = TRUE THEN 1 ELSE 0 END) as active_sessions,
    MAX(last_activity_at) as last_activity,
    MIN(created_at) as first_session
  FROM sessions
  WHERE user_id = p_user_id;
END//

-- Procedure to get audit statistics
CREATE PROCEDURE `sp_get_audit_stats`(
  IN p_start_date DATETIME,
  IN p_end_date DATETIME
)
BEGIN
  SELECT 
    COUNT(*) as total_events,
    COUNT(DISTINCT user_id) as unique_users,
    COUNT(DISTINCT auditable_table) as tables_affected,
    event,
    COUNT(*) as event_count
  FROM audit_logs
  WHERE created_at BETWEEN p_start_date AND p_end_date
  GROUP BY event
  ORDER BY event_count DESC;
END//

-- Procedure to cleanup old audit logs
CREATE PROCEDURE `sp_cleanup_old_audit_logs`(IN p_retention_days INT)
BEGIN
  DELETE FROM audit_logs 
  WHERE created_at < DATE_SUB(NOW(), INTERVAL p_retention_days DAY);
  
  SELECT ROW_COUNT() as deleted_count;
END//

DELIMITER ;

-- ============================================================================
-- INDEXES FOR PERFORMANCE (Additional composite indexes)
-- ============================================================================

-- Composite index for session cleanup
CREATE INDEX `idx_sessions_cleanup` ON `sessions` (`is_active`, `expires_at`);

-- Composite index for audit log queries by table and date
CREATE INDEX `idx_audit_logs_table_date` ON `audit_logs` (`auditable_table`, `created_at`);

-- Composite index for audit log queries by user and event
CREATE INDEX `idx_audit_logs_user_event` ON `audit_logs` (`user_id`, `event`, `created_at`);

-- ============================================================================
-- COMPLETED
-- ============================================================================

SELECT 'Database schema created successfully!' as status;
