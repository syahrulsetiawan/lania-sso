-- Migration: Add temporary_lock_until field to users table
-- Date: 2025-11-11
-- Purpose: Support progressive lockout (5min, 15min, permanent)

ALTER TABLE `users` 
ADD COLUMN `temporary_lock_until` TIMESTAMP NULL AFTER `is_locked`;

-- Add index for better performance on lock checks
CREATE INDEX `idx_temporary_lock_until` ON `users` (`temporary_lock_until`);

-- Update existing locked users to have null temporary_lock_until
UPDATE `users` SET `temporary_lock_until` = NULL WHERE `temporary_lock_until` IS NULL;
