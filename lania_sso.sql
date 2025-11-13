/*
 Navicat Premium Dump SQL

 Source Server         : LOCALHOST PC
 Source Server Type    : MySQL
 Source Server Version : 80030 (8.0.30)
 Source Host           : localhost:3306
 Source Schema         : lania_sso

 Target Server Type    : MySQL
 Target Server Version : 80030 (8.0.30)
 File Encoding         : 65001

 Date: 13/11/2025 22:08:02
*/

SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;

-- ----------------------------
-- Table structure for audit_logs
-- ----------------------------
DROP TABLE IF EXISTS `audit_logs`;
CREATE TABLE `audit_logs`  (
  `id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_type` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `user_id` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `event` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `auditable_table` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `auditable_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `old_values` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `new_values` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `url` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `payload` json NULL,
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `user_agent` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `tags` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  INDEX `audits_auditable_type_auditable_id_index`(`auditable_table` ASC, `auditable_id` ASC) USING BTREE,
  INDEX `audits_user_id_user_type_index`(`user_id` ASC, `user_type` ASC) USING BTREE,
  INDEX `idx_user_id`(`user_id` ASC) USING BTREE,
  INDEX `idx_auditable_table`(`auditable_table` ASC) USING BTREE,
  INDEX `idx_auditable_id`(`auditable_id` ASC) USING BTREE,
  INDEX `idx_event`(`event` ASC) USING BTREE,
  INDEX `idx_user_type`(`user_type` ASC) USING BTREE,
  INDEX `idx_created_at`(`created_at` ASC) USING BTREE,
  INDEX `idx_auditable_table_created_at`(`auditable_table` ASC, `created_at` ASC) USING BTREE,
  INDEX `idx_user_id_event_created_at`(`user_id` ASC, `event` ASC, `created_at` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of audit_logs
-- ----------------------------
INSERT INTO `audit_logs` VALUES ('00f30877-41bf-4003-bfa0-5d1446cedf7c', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'REFRESH_TOKEN_REVOKED', 'refresh_tokens', 'bb8eace1-5db7-42f4-9ad4-b8e2f24efe3a', NULL, NULL, '/api/v1/auth/refresh', 'null', '127.0.0.1', 'Next.js Middleware', 'security,token_revoked', '2025-11-12 13:57:05', '2025-11-12 13:57:05');
INSERT INTO `audit_logs` VALUES ('018afd17-c154-4028-8ed5-c6111256168c', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'TOKEN_REFRESHED', 'refresh_tokens', 'd87a9a01-b044-48e6-a0d2-72723aaaf225', NULL, NULL, '/api/v1/auth/refresh', 'null', '127.0.0.1', 'Next.js Middleware', 'authentication,token_refresh', '2025-11-11 18:05:40', '2025-11-11 18:05:40');
INSERT INTO `audit_logs` VALUES ('076f7009-7e18-4321-ab90-6e64c96b3d9e', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'TOKEN_REFRESHED', 'refresh_tokens', '4cac0ff4-4eb1-4e93-bf48-2a83869769cc', NULL, NULL, '/api/v1/auth/refresh', 'null', '127.0.0.1', 'Next.js Middleware', 'authentication,token_refresh', '2025-11-12 13:52:21', '2025-11-12 13:52:21');
INSERT INTO `audit_logs` VALUES ('089d0a65-0fff-4d5c-b37c-422c545c6f67', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'TOKEN_REFRESHED', 'refresh_tokens', '082a372f-cb01-42dc-8096-35c3eb4e15f1', NULL, NULL, '/api/v1/auth/refresh', 'null', '127.0.0.1', 'Apidog/1.0.0 (https://apidog.com)', 'authentication,token_refresh', '2025-11-11 17:10:29', '2025-11-11 17:10:29');
INSERT INTO `audit_logs` VALUES ('1268dcc8-7adb-4090-88a0-b6f25dd1eab8', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'TOKEN_REFRESHED', 'refresh_tokens', 'a8385cca-5109-46b1-87ac-490f74a8ca20', NULL, NULL, '/api/v1/auth/refresh', 'null', '127.0.0.1', 'Next.js Middleware', 'authentication,token_refresh', '2025-11-12 13:52:59', '2025-11-12 13:52:59');
INSERT INTO `audit_logs` VALUES ('153eded5-ba11-410e-b493-fe27f7aa431d', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'LOGIN_ATTEMPT_TEMPORARY_LOCK', 'users', '790de8f0-0574-4d28-bd62-d04d4a85b793', NULL, NULL, '/api/v1/auth/login', '{\"lockedUntil\": \"2025-11-11T17:45:25.000Z\", \"minutesRemaining\": 3}', '127.0.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1', 'security,authentication', '2025-11-11 17:42:52', '2025-11-11 17:42:52');
INSERT INTO `audit_logs` VALUES ('1e5d6d16-d884-458d-9595-6c71e5480e00', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'login', 'sessions', '790de8f0-0574-4d28-bd62-d04d4a85b793', NULL, NULL, '/api/v1/auth/login', '{\"password\": \"password\", \"rememberMe\": false, \"usernameOrEmail\": \"superadmin\"}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'auth,login', '2025-11-11 17:59:28', '2025-11-11 17:59:28');
INSERT INTO `audit_logs` VALUES ('226c3a12-d3ae-4b55-b596-81a539cd3251', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'TOKEN_REFRESHED', 'refresh_tokens', '6c78f5e4-fb52-4223-be28-63f1f01570b6', NULL, NULL, '/api/v1/auth/refresh', 'null', '127.0.0.1', 'Next.js Middleware', 'authentication,token_refresh', '2025-11-12 13:52:58', '2025-11-12 13:52:58');
INSERT INTO `audit_logs` VALUES ('23eb982a-dcb8-45c4-a44b-ea1b7ad582af', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'TOKEN_REFRESHED', 'refresh_tokens', 'd8068d99-7913-4a55-b557-946c8bf4fd19', NULL, NULL, '/api/v1/auth/refresh', 'null', '127.0.0.1', 'Next.js Middleware', 'authentication,token_refresh', '2025-11-12 13:53:28', '2025-11-12 13:53:28');
INSERT INTO `audit_logs` VALUES ('24d03814-f567-4177-978a-6ecc71c6172c', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'REFRESH_TOKEN_REVOKED', 'refresh_tokens', 'e069c9c7-49bc-4a80-9c65-9f1afa5672ae', NULL, NULL, '/api/v1/auth/refresh', 'null', '127.0.0.1', 'Next.js Middleware', 'security,token_revoked', '2025-11-12 13:52:21', '2025-11-12 13:52:21');
INSERT INTO `audit_logs` VALUES ('268b1524-e59c-4d65-a269-867453c67052', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'TOKEN_REFRESHED', 'refresh_tokens', 'aad7fe0e-28c1-4d00-b83a-0d294aceead8', NULL, NULL, '/api/v1/auth/refresh', 'null', '127.0.0.1', 'Next.js Middleware', 'authentication,token_refresh', '2025-11-11 18:04:47', '2025-11-11 18:04:47');
INSERT INTO `audit_logs` VALUES ('283bda24-f92a-411a-8544-e0e47b91a4b1', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'ACCOUNT_TEMPORARY_LOCK_5MIN', 'users', '790de8f0-0574-4d28-bd62-d04d4a85b793', NULL, NULL, '/api/v1/auth/login', '{\"lockedUntil\": \"2025-11-11T17:53:27.174Z\", \"lockDuration\": \"5_minutes\", \"failedAttempts\": 1}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'security,temporary_lock', '2025-11-11 17:48:27', '2025-11-11 17:48:27');
INSERT INTO `audit_logs` VALUES ('2b04ecf5-93d5-491b-9e98-1afa9bbe5afe', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'TOKEN_REFRESHED', 'refresh_tokens', '97853d61-95de-46cf-a165-11b20fe538d3', NULL, NULL, '/api/v1/auth/refresh', 'null', '127.0.0.1', 'Next.js Middleware', 'authentication,token_refresh', '2025-11-12 13:55:09', '2025-11-12 13:55:09');
INSERT INTO `audit_logs` VALUES ('378c2aa6-65d6-47b2-9b05-243342489565', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'login', 'sessions', '790de8f0-0574-4d28-bd62-d04d4a85b793', NULL, NULL, '/api/v1/auth/login', '{\"password\": \"password\", \"rememberMe\": false, \"usernameOrEmail\": \"superadmin\"}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'auth,login', '2025-11-12 17:22:50', '2025-11-12 17:22:50');
INSERT INTO `audit_logs` VALUES ('3a8044fc-e268-4f03-9890-4d5de1cd9869', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'LOGIN_ATTEMPT_TEMPORARY_LOCK', 'users', '790de8f0-0574-4d28-bd62-d04d4a85b793', NULL, NULL, '/api/v1/auth/login', '{\"lockedUntil\": \"2025-11-11T17:45:25.000Z\", \"minutesRemaining\": 3}', '127.0.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1', 'security,authentication', '2025-11-11 17:43:20', '2025-11-11 17:43:20');
INSERT INTO `audit_logs` VALUES ('42368a6f-d362-4112-9b01-48b2ea662351', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'login', 'sessions', '790de8f0-0574-4d28-bd62-d04d4a85b793', NULL, NULL, '/api/v1/auth/login', '{\"password\": \"password\", \"rememberMe\": false, \"usernameOrEmail\": \"superadmin\"}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'auth,login', '2025-11-12 14:39:37', '2025-11-12 14:39:37');
INSERT INTO `audit_logs` VALUES ('43081c5f-ffd5-4c39-bb84-bcb6aee7d555', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'TOKEN_REFRESHED', 'refresh_tokens', '0eb47daf-7d9b-48c3-9e03-a60a0f80b92b', NULL, NULL, '/api/v1/auth/refresh', 'null', '127.0.0.1', 'Next.js Middleware', 'authentication,token_refresh', '2025-11-11 18:05:28', '2025-11-11 18:05:28');
INSERT INTO `audit_logs` VALUES ('43c79227-163b-4357-a08e-ebfb91361006', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'TOKEN_REFRESHED', 'refresh_tokens', 'a1a898e2-b96b-4167-a973-fd3cdc35bc5f', NULL, NULL, '/api/v1/auth/refresh', 'null', '127.0.0.1', 'Next.js Middleware', 'authentication,token_refresh', '2025-11-12 13:42:08', '2025-11-12 13:42:08');
INSERT INTO `audit_logs` VALUES ('46f9b46c-d7c1-48e4-a351-79e63e70bda0', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'LOGIN_ATTEMPT_TEMPORARY_LOCK', 'users', '790de8f0-0574-4d28-bd62-d04d4a85b793', NULL, NULL, '/api/v1/auth/login', '{\"lockedUntil\": \"2025-11-11T17:45:25.000Z\", \"minutesRemaining\": 3}', '127.0.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1', 'security,authentication', '2025-11-11 17:42:56', '2025-11-11 17:42:56');
INSERT INTO `audit_logs` VALUES ('4c471ee2-49d8-45fa-8edc-dabb9be4abeb', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'TOKEN_REFRESHED', 'refresh_tokens', '2219f561-ebfc-47fe-908f-703d2a5aaf21', NULL, NULL, '/api/v1/auth/refresh', 'null', '127.0.0.1', 'Next.js Middleware', 'authentication,token_refresh', '2025-11-12 13:55:06', '2025-11-12 13:55:06');
INSERT INTO `audit_logs` VALUES ('4dbf642e-7a17-4980-884b-bdf405d738b6', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'TOKEN_REFRESHED', 'refresh_tokens', '2c8ec29e-8a9a-4c9e-9c20-fc4aa3172a49', NULL, NULL, '/api/v1/auth/refresh', 'null', '127.0.0.1', 'Next.js Middleware', 'authentication,token_refresh', '2025-11-11 18:03:41', '2025-11-11 18:03:41');
INSERT INTO `audit_logs` VALUES ('4fb8a097-3f76-4d54-ae18-9d416dba7c70', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'TOKEN_REFRESHED', 'refresh_tokens', '155aac8d-20d3-41b4-8c2f-b9ab7bc722be', NULL, NULL, '/api/v1/auth/refresh', 'null', '127.0.0.1', 'Next.js Middleware', 'authentication,token_refresh', '2025-11-12 13:51:00', '2025-11-12 13:51:00');
INSERT INTO `audit_logs` VALUES ('4fe7385c-41c0-443c-b058-1f7a2905eb1f', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'REFRESH_TOKEN_REVOKED', 'refresh_tokens', '00a3a079-2bb9-433f-98ae-c9b3b9dfee57', NULL, NULL, '/api/v1/auth/refresh', 'null', '127.0.0.1', 'Next.js Middleware', 'security,token_revoked', '2025-11-12 13:56:57', '2025-11-12 13:56:57');
INSERT INTO `audit_logs` VALUES ('5256437d-4912-4c69-b237-f0e6531fc786', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'LOGIN_ATTEMPT_TEMPORARY_LOCK', 'users', '790de8f0-0574-4d28-bd62-d04d4a85b793', NULL, NULL, '/api/v1/auth/login', '{\"lockedUntil\": \"2025-11-11T16:42:14.000Z\", \"minutesRemaining\": 1}', '127.0.0.1', 'Apidog/1.0.0 (https://apidog.com)', 'security,authentication', '2025-11-11 16:41:14', '2025-11-11 16:41:14');
INSERT INTO `audit_logs` VALUES ('58e45116-120e-455d-b050-56032e61eac6', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'LOGIN_ATTEMPT_TEMPORARY_LOCK', 'users', '790de8f0-0574-4d28-bd62-d04d4a85b793', NULL, NULL, '/api/v1/auth/login', '{\"lockedUntil\": \"2025-11-11T17:45:25.000Z\", \"minutesRemaining\": 2}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'security,authentication', '2025-11-11 17:43:59', '2025-11-11 17:43:59');
INSERT INTO `audit_logs` VALUES ('5b828c9e-2211-4f7b-a746-45249efa3720', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'TOKEN_REFRESHED', 'refresh_tokens', '00a3a079-2bb9-433f-98ae-c9b3b9dfee57', NULL, NULL, '/api/v1/auth/refresh', 'null', '127.0.0.1', 'Next.js Middleware', 'authentication,token_refresh', '2025-11-12 13:56:57', '2025-11-12 13:56:57');
INSERT INTO `audit_logs` VALUES ('5c3172a4-b4a7-44bd-a553-6cb277408b2f', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'TOKEN_REFRESHED', 'refresh_tokens', '426140cc-fc8a-4faf-87af-edd14d4363f4', NULL, NULL, '/api/v1/auth/refresh', 'null', '127.0.0.1', 'Next.js Middleware', 'authentication,token_refresh', '2025-11-11 18:39:47', '2025-11-11 18:39:47');
INSERT INTO `audit_logs` VALUES ('628986ec-623c-4010-90c3-9b75a0965bd3', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'LOGIN_ATTEMPT_TEMPORARY_LOCK', 'users', '790de8f0-0574-4d28-bd62-d04d4a85b793', NULL, NULL, '/api/v1/auth/login', '{\"lockedUntil\": \"2025-11-11T17:45:25.000Z\", \"minutesRemaining\": 3}', '127.0.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1', 'security,authentication', '2025-11-11 17:42:48', '2025-11-11 17:42:48');
INSERT INTO `audit_logs` VALUES ('6b9a0985-2376-4558-b232-c3fa6d8db7c7', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'TOKEN_REFRESHED', 'refresh_tokens', 'e12556b8-59bd-4bb1-aea9-adb79dfe7435', NULL, NULL, '/api/v1/auth/refresh', 'null', '127.0.0.1', 'Next.js Middleware', 'authentication,token_refresh', '2025-11-11 18:05:43', '2025-11-11 18:05:43');
INSERT INTO `audit_logs` VALUES ('6cf01efa-8b1f-41be-9298-67f766a720f2', 'System', 'superadmin', 'login_failed', 'users', 'unknown', NULL, NULL, '/api/v1/auth/login', '{\"password\": \"pasdasdasd\", \"rememberMe\": false, \"usernameOrEmail\": \"superadmin\"}', '127.0.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1', 'auth,login_failed,security', '2025-11-11 17:40:25', '2025-11-11 17:40:25');
INSERT INTO `audit_logs` VALUES ('702e029a-03fa-47f0-9ef5-8231085f27b9', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'TOKEN_REFRESHED', 'refresh_tokens', '7aeeccbe-22e8-41d1-80ca-47b4c6e3835f', NULL, NULL, '/api/v1/auth/refresh', 'null', '127.0.0.1', 'Next.js Middleware', 'authentication,token_refresh', '2025-11-12 13:58:08', '2025-11-12 13:58:08');
INSERT INTO `audit_logs` VALUES ('7348764b-06c9-4acc-9a55-fa22f6476b9e', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'LOGIN_ATTEMPT_TEMPORARY_LOCK', 'users', '790de8f0-0574-4d28-bd62-d04d4a85b793', NULL, NULL, '/api/v1/auth/login', '{\"lockedUntil\": \"2025-11-11T16:42:14.000Z\", \"minutesRemaining\": 1}', '127.0.0.1', 'Apidog/1.0.0 (https://apidog.com)', 'security,authentication', '2025-11-11 16:41:29', '2025-11-11 16:41:29');
INSERT INTO `audit_logs` VALUES ('7432d0e4-2e61-4745-82a7-a4b66a80ab16', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'login', 'sessions', '790de8f0-0574-4d28-bd62-d04d4a85b793', NULL, NULL, '/api/v1/auth/login', '{\"password\": \"password\", \"rememberMe\": true, \"usernameOrEmail\": \"superadmin\"}', '127.0.0.1', 'Apidog/1.0.0 (https://apidog.com)', 'auth,login', '2025-11-11 16:41:54', '2025-11-11 16:41:54');
INSERT INTO `audit_logs` VALUES ('7553f558-9159-4f45-837d-4b143c432990', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'LOGIN_ATTEMPT_TEMPORARY_LOCK', 'users', '790de8f0-0574-4d28-bd62-d04d4a85b793', NULL, NULL, '/api/v1/auth/login', '{\"lockedUntil\": \"2025-11-11T17:45:25.000Z\", \"minutesRemaining\": 4}', '127.0.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1', 'security,authentication', '2025-11-11 17:41:54', '2025-11-11 17:41:54');
INSERT INTO `audit_logs` VALUES ('772835e2-63e6-4dd1-b3df-b652bae8ffe4', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'login', 'sessions', '790de8f0-0574-4d28-bd62-d04d4a85b793', NULL, NULL, '/api/v1/auth/login', '{\"password\": \"password\", \"rememberMe\": false, \"usernameOrEmail\": \"superadmin\"}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'auth,login', '2025-11-11 18:02:09', '2025-11-11 18:02:09');
INSERT INTO `audit_logs` VALUES ('7815bbc1-c884-4af9-8284-e13b738c51e8', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'login', 'sessions', '790de8f0-0574-4d28-bd62-d04d4a85b793', NULL, NULL, '/api/v1/auth/login', '{\"password\": \"password\", \"rememberMe\": false, \"usernameOrEmail\": \"superadmin\"}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'auth,login', '2025-11-11 17:59:47', '2025-11-11 17:59:47');
INSERT INTO `audit_logs` VALUES ('7b971b7e-eb2f-4e3e-8914-80d016623aa7', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'login', 'sessions', '790de8f0-0574-4d28-bd62-d04d4a85b793', NULL, NULL, '/api/v1/auth/login', '{\"password\": \"password\", \"rememberMe\": false, \"usernameOrEmail\": \"superadmin\"}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'auth,login', '2025-11-12 14:06:19', '2025-11-12 14:06:19');
INSERT INTO `audit_logs` VALUES ('7dbee333-52c9-4029-a2ed-f74a1a154186', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'LOGIN_ATTEMPT_TEMPORARY_LOCK', 'users', '790de8f0-0574-4d28-bd62-d04d4a85b793', NULL, NULL, '/api/v1/auth/login', '{\"lockedUntil\": \"2025-11-11T16:42:14.000Z\", \"minutesRemaining\": 3}', '127.0.0.1', 'Apidog/1.0.0 (https://apidog.com)', 'security,authentication', '2025-11-11 16:39:32', '2025-11-11 16:39:32');
INSERT INTO `audit_logs` VALUES ('7e396b4d-dae0-4352-9fdf-dd7bd6aff50f', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'TOKEN_REFRESHED', 'refresh_tokens', '90ef85bd-190f-4eb2-80b2-21209b50fe85', NULL, NULL, '/api/v1/auth/refresh', 'null', '127.0.0.1', 'Next.js Middleware', 'authentication,token_refresh', '2025-11-11 18:05:39', '2025-11-11 18:05:39');
INSERT INTO `audit_logs` VALUES ('825c5455-e54c-4d85-9aed-9db5345e1421', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'TOKEN_REFRESHED', 'refresh_tokens', '767dad56-7748-45b9-b937-00401f3927bd', NULL, NULL, '/api/v1/auth/refresh', 'null', '127.0.0.1', 'Next.js Middleware', 'authentication,token_refresh', '2025-11-11 17:59:31', '2025-11-11 17:59:31');
INSERT INTO `audit_logs` VALUES ('83c7532f-c862-495d-afdc-e9e218213c6a', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'login', 'sessions', '790de8f0-0574-4d28-bd62-d04d4a85b793', NULL, NULL, '/api/v1/auth/login', '{\"password\": \"password\", \"rememberMe\": false, \"usernameOrEmail\": \"superadmin\"}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'auth,login', '2025-11-12 13:58:07', '2025-11-12 13:58:07');
INSERT INTO `audit_logs` VALUES ('851a6b14-7f03-4870-8a18-028d3cd42e17', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'ACCOUNT_TEMPORARY_LOCK_5MIN', 'users', '790de8f0-0574-4d28-bd62-d04d4a85b793', NULL, NULL, '/api/v1/auth/login', '{\"lockedUntil\": \"2025-11-11T17:45:24.654Z\", \"lockDuration\": \"5_minutes\", \"failedAttempts\": 1}', '127.0.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1', 'security,temporary_lock', '2025-11-11 17:40:25', '2025-11-11 17:40:25');
INSERT INTO `audit_logs` VALUES ('894bdd18-7413-4c9b-8be2-03b059d2dca1', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'TOKEN_REFRESHED', 'refresh_tokens', '30448482-1dc6-4cb0-b568-0856f2c13ea1', NULL, NULL, '/api/v1/auth/refresh', 'null', '127.0.0.1', 'Next.js Middleware', 'authentication,token_refresh', '2025-11-12 13:57:04', '2025-11-12 13:57:04');
INSERT INTO `audit_logs` VALUES ('92a95784-db89-4b2d-b2c8-a0040a4dceff', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'TOKEN_REFRESHED', 'refresh_tokens', 'ca81d931-326e-4bcc-8c2c-4f4400115e9f', NULL, NULL, '/api/v1/auth/refresh', 'null', '127.0.0.1', 'Next.js Middleware', 'authentication,token_refresh', '2025-11-11 18:04:48', '2025-11-11 18:04:48');
INSERT INTO `audit_logs` VALUES ('951137e4-b481-45a8-a86d-ce171feff5b6', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'login', 'sessions', '790de8f0-0574-4d28-bd62-d04d4a85b793', NULL, NULL, '/api/v1/auth/login', '{\"latitude\": \"-6.200000\", \"password\": \"password\", \"longitude\": \"106.816666\", \"deviceName\": \"Chrome on Windows\", \"rememberMe\": false, \"usernameOrEmail\": \"superadmin\"}', '127.0.0.1', 'Apidog/1.0.0 (https://apidog.com)', 'auth,login', '2025-11-11 16:43:06', '2025-11-11 16:43:06');
INSERT INTO `audit_logs` VALUES ('95dc75c6-029e-4084-9cca-0337bbd1b2c2', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'TOKEN_REFRESHED', 'refresh_tokens', 'af6cf8ca-2aa2-464f-b812-444ba8f7431e', NULL, NULL, '/api/v1/auth/refresh', 'null', '127.0.0.1', 'Next.js Middleware', 'authentication,token_refresh', '2025-11-12 13:48:03', '2025-11-12 13:48:03');
INSERT INTO `audit_logs` VALUES ('964d86f9-5eae-4c36-91bf-7add10775223', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'login', 'sessions', '790de8f0-0574-4d28-bd62-d04d4a85b793', NULL, NULL, '/api/v1/auth/login', '{\"password\": \"password\", \"rememberMe\": false, \"usernameOrEmail\": \"superadmin\"}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'auth,login', '2025-11-11 17:59:36', '2025-11-11 17:59:36');
INSERT INTO `audit_logs` VALUES ('9682c65d-8703-429b-b93b-9f8dda817960', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'TOKEN_REFRESHED', 'refresh_tokens', 'adf00832-8b3e-4045-b866-75edd91531ec', NULL, NULL, '/api/v1/auth/refresh', 'null', '127.0.0.1', 'Next.js Middleware', 'authentication,token_refresh', '2025-11-11 18:03:49', '2025-11-11 18:03:49');
INSERT INTO `audit_logs` VALUES ('971505f3-3cf9-491a-bd01-610dab78c580', 'System', 'superadmin', 'login_failed', 'users', 'unknown', NULL, NULL, '/api/v1/auth/login', '{\"password\": \"pasdasdasd\", \"rememberMe\": false, \"usernameOrEmail\": \"superadmin\"}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'auth,login_failed,security', '2025-11-11 17:48:27', '2025-11-11 17:48:27');
INSERT INTO `audit_logs` VALUES ('9a19d4fc-7e3f-47f2-830f-59fdbe725aa5', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'REFRESH_TOKEN_REVOKED', 'refresh_tokens', '7aeeccbe-22e8-41d1-80ca-47b4c6e3835f', NULL, NULL, '/api/v1/auth/refresh', 'null', '127.0.0.1', 'Next.js Middleware', 'security,token_revoked', '2025-11-12 13:58:08', '2025-11-12 13:58:08');
INSERT INTO `audit_logs` VALUES ('9f138e36-28d6-4f2d-954a-62c7f6ac6aa6', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'TOKEN_REFRESHED', 'refresh_tokens', '85740c02-a7b5-4624-906d-0d8a0333948b', NULL, NULL, '/api/v1/auth/refresh', 'null', '127.0.0.1', 'Next.js Middleware', 'authentication,token_refresh', '2025-11-13 14:01:49', '2025-11-13 14:01:49');
INSERT INTO `audit_logs` VALUES ('a4cffe85-d1b2-43eb-a72e-790d89b2f4af', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'TOKEN_REFRESHED', 'refresh_tokens', '279118ae-5841-4ab2-ad2f-3d276083bf50', NULL, NULL, '/api/v1/auth/refresh', 'null', '127.0.0.1', 'Next.js Middleware', 'authentication,token_refresh', '2025-11-11 18:03:59', '2025-11-11 18:03:59');
INSERT INTO `audit_logs` VALUES ('a5982120-7e4b-4dbc-8ab8-64894903f42c', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'login', 'sessions', '790de8f0-0574-4d28-bd62-d04d4a85b793', NULL, NULL, '/api/v1/auth/login', '{\"password\": \"password\", \"rememberMe\": false, \"usernameOrEmail\": \"superadmin\"}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'auth,login', '2025-11-12 13:57:04', '2025-11-12 13:57:04');
INSERT INTO `audit_logs` VALUES ('a932c0a6-8a79-42c9-8f5f-0095cb9e4678', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'TOKEN_REFRESHED', 'refresh_tokens', 'a8fb3aee-c9bb-469d-a23f-75e945e4262f', NULL, NULL, '/api/v1/auth/refresh', 'null', '127.0.0.1', 'Next.js Middleware', 'authentication,token_refresh', '2025-11-11 18:03:59', '2025-11-11 18:03:59');
INSERT INTO `audit_logs` VALUES ('aa0e4333-8352-4e87-be3a-d46662e4b0a2', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'TOKEN_REFRESHED', 'refresh_tokens', 'bb8eace1-5db7-42f4-9ad4-b8e2f24efe3a', NULL, NULL, '/api/v1/auth/refresh', 'null', '127.0.0.1', 'Next.js Middleware', 'authentication,token_refresh', '2025-11-12 13:57:05', '2025-11-12 13:57:05');
INSERT INTO `audit_logs` VALUES ('af002866-eacc-44f8-ba5e-57f5d5f6a165', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'LOGIN_ATTEMPT_TEMPORARY_LOCK', 'users', '790de8f0-0574-4d28-bd62-d04d4a85b793', NULL, NULL, '/api/v1/auth/login', '{\"lockedUntil\": \"2025-11-11T17:45:25.000Z\", \"minutesRemaining\": 2}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'security,authentication', '2025-11-11 17:44:07', '2025-11-11 17:44:07');
INSERT INTO `audit_logs` VALUES ('b1c33f7d-54e2-4381-ad65-92cdddb64668', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'TOKEN_REFRESHED', 'refresh_tokens', '71f89942-5481-46a7-9e34-b10c8d8450b9', NULL, NULL, '/api/v1/auth/refresh', 'null', '127.0.0.1', 'Next.js Middleware', 'authentication,token_refresh', '2025-11-11 18:05:41', '2025-11-11 18:05:41');
INSERT INTO `audit_logs` VALUES ('b6e502de-5db3-445d-a367-f62f6dcd63eb', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'login', 'sessions', '790de8f0-0574-4d28-bd62-d04d4a85b793', NULL, NULL, '/api/v1/auth/login', '{\"password\": \"password\", \"rememberMe\": false, \"usernameOrEmail\": \"superadmin\"}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'auth,login', '2025-11-12 15:19:59', '2025-11-12 15:19:59');
INSERT INTO `audit_logs` VALUES ('bb45c491-6649-4100-b4d2-9dfed96c7489', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'login', 'sessions', '790de8f0-0574-4d28-bd62-d04d4a85b793', NULL, NULL, '/api/v1/auth/login', '{\"password\": \"password\", \"rememberMe\": false, \"usernameOrEmail\": \"superadmin\"}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'auth,login', '2025-11-11 18:00:51', '2025-11-11 18:00:51');
INSERT INTO `audit_logs` VALUES ('bd4ff721-c237-46e5-906a-ee18121e4569', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'LOGIN_ATTEMPT_TEMPORARY_LOCK', 'users', '790de8f0-0574-4d28-bd62-d04d4a85b793', NULL, NULL, '/api/v1/auth/login', '{\"lockedUntil\": \"2025-11-11T17:45:25.000Z\", \"minutesRemaining\": 2}', '127.0.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1', 'security,authentication', '2025-11-11 17:43:27', '2025-11-11 17:43:27');
INSERT INTO `audit_logs` VALUES ('bf533553-21cc-4dc7-b558-6fd48522c838', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'LOGIN_ATTEMPT_TEMPORARY_LOCK', 'users', '790de8f0-0574-4d28-bd62-d04d4a85b793', NULL, NULL, '/api/v1/auth/login', '{\"lockedUntil\": \"2025-11-11T17:45:25.000Z\", \"minutesRemaining\": 3}', '127.0.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1', 'security,authentication', '2025-11-11 17:43:10', '2025-11-11 17:43:10');
INSERT INTO `audit_logs` VALUES ('bfa45cb3-e6b7-4996-a9df-d50c65ddfb8b', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'LOGIN_ATTEMPT_TEMPORARY_LOCK', 'users', '790de8f0-0574-4d28-bd62-d04d4a85b793', NULL, NULL, '/api/v1/auth/login', '{\"lockedUntil\": \"2025-11-11T17:45:25.000Z\", \"minutesRemaining\": 3}', '127.0.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1', 'security,authentication', '2025-11-11 17:42:39', '2025-11-11 17:42:39');
INSERT INTO `audit_logs` VALUES ('d236ed16-fd63-4543-9eb7-ee917351f894', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'TOKEN_REFRESHED', 'refresh_tokens', '80c0f562-3c80-41f1-9eba-41f7df84120c', NULL, NULL, '/api/v1/auth/refresh', 'null', '127.0.0.1', 'Next.js Middleware', 'authentication,token_refresh', '2025-11-11 18:04:06', '2025-11-11 18:04:06');
INSERT INTO `audit_logs` VALUES ('d6d96bbd-c9c5-47bd-9aab-31848f14b4ca', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'login', 'sessions', '790de8f0-0574-4d28-bd62-d04d4a85b793', NULL, NULL, '/api/v1/auth/login', '{\"password\": \"password\", \"rememberMe\": false, \"usernameOrEmail\": \"superadmin\"}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'auth,login', '2025-11-12 16:29:45', '2025-11-12 16:29:45');
INSERT INTO `audit_logs` VALUES ('d7dfb85b-f186-4ca4-a83a-5e6be33fdcb3', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'TOKEN_REFRESHED', 'refresh_tokens', '4a83bdf7-43f4-4429-b407-367eed74acd0', NULL, NULL, '/api/v1/auth/refresh', 'null', '127.0.0.1', 'Next.js Middleware', 'authentication,token_refresh', '2025-11-12 13:52:34', '2025-11-12 13:52:34');
INSERT INTO `audit_logs` VALUES ('d84771b7-ba89-43b5-9022-1ab28d47d87b', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'TOKEN_REFRESHED', 'refresh_tokens', '32f9ea9c-189c-43ef-9e96-2a6024d67aa9', NULL, NULL, '/api/v1/auth/refresh', 'null', '127.0.0.1', 'Next.js Middleware', 'authentication,token_refresh', '2025-11-12 13:54:52', '2025-11-12 13:54:52');
INSERT INTO `audit_logs` VALUES ('d9a4012a-3a77-4f04-9ed4-318f03196391', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'TOKEN_REFRESHED', 'refresh_tokens', '17593e5e-73e6-427f-bf9b-d141421aee80', NULL, NULL, '/api/v1/auth/refresh', 'null', '127.0.0.1', 'Next.js Middleware', 'authentication,token_refresh', '2025-11-12 13:54:52', '2025-11-12 13:54:52');
INSERT INTO `audit_logs` VALUES ('db8b2ec7-1e59-429e-a6a5-330e908d5fc5', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'LOGIN_ATTEMPT_TEMPORARY_LOCK', 'users', '790de8f0-0574-4d28-bd62-d04d4a85b793', NULL, NULL, '/api/v1/auth/login', '{\"lockedUntil\": \"2025-11-11T17:45:25.000Z\", \"minutesRemaining\": 2}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'security,authentication', '2025-11-11 17:44:17', '2025-11-11 17:44:17');
INSERT INTO `audit_logs` VALUES ('dba95ae5-2847-466d-a564-506fd569a7ae', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'TOKEN_REFRESHED', 'refresh_tokens', 'e1699d41-28e6-4899-b16a-e530956175ee', NULL, NULL, '/api/v1/auth/refresh', 'null', '127.0.0.1', 'Next.js Middleware', 'authentication,token_refresh', '2025-11-12 13:55:10', '2025-11-12 13:55:10');
INSERT INTO `audit_logs` VALUES ('de1518d4-aa8d-492e-a613-9030512f435b', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'TOKEN_REFRESHED', 'refresh_tokens', 'e069c9c7-49bc-4a80-9c65-9f1afa5672ae', NULL, NULL, '/api/v1/auth/refresh', 'null', '127.0.0.1', 'Next.js Middleware', 'authentication,token_refresh', '2025-11-12 13:52:21', '2025-11-12 13:52:21');
INSERT INTO `audit_logs` VALUES ('de533a4c-bf06-4a87-a51c-122a9355cb2b', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'TOKEN_REFRESHED', 'refresh_tokens', '1ec9aeb2-ef6c-4690-81cc-211515c85b20', NULL, NULL, '/api/v1/auth/refresh', 'null', '127.0.0.1', 'Next.js Middleware', 'authentication,token_refresh', '2025-11-12 13:52:40', '2025-11-12 13:52:40');
INSERT INTO `audit_logs` VALUES ('e0054de4-1925-427c-8069-06650a0b111c', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'LOGIN_ATTEMPT_TEMPORARY_LOCK', 'users', '790de8f0-0574-4d28-bd62-d04d4a85b793', NULL, NULL, '/api/v1/auth/login', '{\"lockedUntil\": \"2025-11-11T17:45:25.000Z\", \"minutesRemaining\": 2}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'security,authentication', '2025-11-11 17:44:23', '2025-11-11 17:44:23');
INSERT INTO `audit_logs` VALUES ('e4d44916-ba0d-4c3a-b031-51c957133778', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'TOKEN_REFRESHED', 'refresh_tokens', 'efcb9da7-90c5-4a06-a0e9-ea4e8258f0a3', NULL, NULL, '/api/v1/auth/refresh', 'null', '127.0.0.1', 'Next.js Middleware', 'authentication,token_refresh', '2025-11-12 13:53:28', '2025-11-12 13:53:28');
INSERT INTO `audit_logs` VALUES ('e5d21f48-3986-4110-9e9f-db68df959177', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'TOKEN_REFRESHED', 'refresh_tokens', '89cd9109-5637-47f1-934f-e7bfc1be8848', NULL, NULL, '/api/v1/auth/refresh', 'null', '127.0.0.1', 'Next.js Middleware', 'authentication,token_refresh', '2025-11-11 18:05:42', '2025-11-11 18:05:42');
INSERT INTO `audit_logs` VALUES ('ea56b401-ecd9-4b0e-91db-2fc18028b3ff', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'REFRESH_TOKEN_REVOKED', 'refresh_tokens', '4cac0ff4-4eb1-4e93-bf48-2a83869769cc', NULL, NULL, '/api/v1/auth/refresh', 'null', '127.0.0.1', 'Next.js Middleware', 'security,token_revoked', '2025-11-12 13:52:25', '2025-11-12 13:52:25');
INSERT INTO `audit_logs` VALUES ('eb82d4ee-3b7f-47b1-9c46-24454133bf7a', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'LOGIN_ATTEMPT_TEMPORARY_LOCK', 'users', '790de8f0-0574-4d28-bd62-d04d4a85b793', NULL, NULL, '/api/v1/auth/login', '{\"lockedUntil\": \"2025-11-11T17:45:25.000Z\", \"minutesRemaining\": 3}', '127.0.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1', 'security,authentication', '2025-11-11 17:43:00', '2025-11-11 17:43:00');
INSERT INTO `audit_logs` VALUES ('ec9b0c08-3d48-4eb6-909c-61008620d7b2', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'TOKEN_REFRESHED', 'refresh_tokens', 'd3c39e19-5d3c-4e3b-8e49-67282ab1a8dc', NULL, NULL, '/api/v1/auth/refresh', 'null', '127.0.0.1', 'Next.js Middleware', 'authentication,token_refresh', '2025-11-11 18:05:40', '2025-11-11 18:05:40');
INSERT INTO `audit_logs` VALUES ('ecc9ccaf-981c-425f-8203-eb63b9fefbef', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'login', 'sessions', '790de8f0-0574-4d28-bd62-d04d4a85b793', NULL, NULL, '/api/v1/auth/login', '{\"password\": \"password\", \"rememberMe\": false, \"usernameOrEmail\": \"superadmin\"}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'auth,login', '2025-11-11 18:01:28', '2025-11-11 18:01:28');
INSERT INTO `audit_logs` VALUES ('f1ccd195-4713-49c6-9288-393da07fb3e7', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'login', 'sessions', '790de8f0-0574-4d28-bd62-d04d4a85b793', NULL, NULL, '/api/v1/auth/login', '{\"password\": \"password\", \"rememberMe\": false, \"usernameOrEmail\": \"superadmin\"}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'auth,login', '2025-11-11 18:03:41', '2025-11-11 18:03:41');
INSERT INTO `audit_logs` VALUES ('f70c4de2-9a9f-4d53-adac-56d8a2aad736', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'TOKEN_REFRESHED', 'refresh_tokens', '4917a00c-5e63-4f32-a23b-7f9d68f85ef2', NULL, NULL, '/api/v1/auth/refresh', 'null', '127.0.0.1', 'Next.js Middleware', 'authentication,token_refresh', '2025-11-12 13:58:07', '2025-11-12 13:58:07');
INSERT INTO `audit_logs` VALUES ('f7eeaf1a-25a5-4777-9ece-84b1896fe714', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'TOKEN_REFRESHED', 'refresh_tokens', 'dff522dc-cb7c-4b5a-a813-d305b6064fcc', NULL, NULL, '/api/v1/auth/refresh', 'null', '127.0.0.1', 'Next.js Middleware', 'authentication,token_refresh', '2025-11-11 18:03:51', '2025-11-11 18:03:51');
INSERT INTO `audit_logs` VALUES ('f89c6d82-cc6e-4b9d-a905-8ebeaa60712a', 'User', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'login', 'sessions', '790de8f0-0574-4d28-bd62-d04d4a85b793', NULL, NULL, '/api/v1/auth/login', '{\"password\": \"password\", \"rememberMe\": false, \"usernameOrEmail\": \"superadmin\"}', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'auth,login', '2025-11-12 13:52:34', '2025-11-12 13:52:34');

-- ----------------------------
-- Table structure for core_licenses
-- ----------------------------
DROP TABLE IF EXISTS `core_licenses`;
CREATE TABLE `core_licenses`  (
  `key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `default_value` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`key`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of core_licenses
-- ----------------------------
INSERT INTO `core_licenses` VALUES ('company_branches', 'Company Branches', 'The geographical location associated with the license.', '1', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `core_licenses` VALUES ('due_payment_days', 'Due Payment Days', 'The due payment days for the license.', '30', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `core_licenses` VALUES ('feature_access', 'Feature Access', 'The features accessible with the license.', 'basic', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `core_licenses` VALUES ('max_users', 'Maximum Users', 'The maximum number of users allowed for the license.', '100', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `core_licenses` VALUES ('storage_limit', 'Storage Limit', 'The storage limit in MB for the license.', '1024', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `core_licenses` VALUES ('support_level', 'Support Level', 'The level of support provided with the license.', 'standard', '2025-11-05 23:38:09', '2025-11-05 23:38:09');

-- ----------------------------
-- Table structure for core_services
-- ----------------------------
DROP TABLE IF EXISTS `core_services`;
CREATE TABLE `core_services`  (
  `key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `icon` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`key`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of core_services
-- ----------------------------
INSERT INTO `core_services` VALUES ('accounting', 'Accounting Service', 'Provides accounting features and support.', 'accounting-icon.png', 1, '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `core_services` VALUES ('admin_portal', 'Admin Portal Service', 'Provides admin portal features and support.', 'admin-portal-icon.png', 1, '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `core_services` VALUES ('finance', 'Finance Service', 'Provides finance features and support.', 'finance-icon.png', 1, '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `core_services` VALUES ('management_stock', 'Management Stock Service', 'Provides management stock features and support.', 'management-stock-icon.png', 1, '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `core_services` VALUES ('procurement', 'Procurement Service', 'Provides procurement features and support.', 'procurement-icon.png', 1, '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `core_services` VALUES ('salesorder', 'Sales Order Service', 'Provides sales order features and support.', 'sales-order-icon.png', 1, '2025-11-05 23:38:09', '2025-11-05 23:38:09');

-- ----------------------------
-- Table structure for core_status_tenants
-- ----------------------------
DROP TABLE IF EXISTS `core_status_tenants`;
CREATE TABLE `core_status_tenants`  (
  `key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `description` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`key`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of core_status_tenants
-- ----------------------------
INSERT INTO `core_status_tenants` VALUES ('active', 'Active', 'The tenant is active and operational.', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `core_status_tenants` VALUES ('closed', 'Closed', 'The tenant has been closed and is no longer operational.', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `core_status_tenants` VALUES ('expired', 'Expired', 'The tenants subscription or license has expired.', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `core_status_tenants` VALUES ('inactive', 'Inactive', 'The tenant is inactive and not operational.', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `core_status_tenants` VALUES ('overdue', 'Overdue', 'The tenant has overdue payments.', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `core_status_tenants` VALUES ('pending', 'Pending', 'The tenant is pending activation or approval.', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `core_status_tenants` VALUES ('suspended', 'Suspended', 'The tenant is suspended due to violations or non-payment.', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `core_status_tenants` VALUES ('trial', 'Trial', 'The tenant is in a trial period.', '2025-11-05 23:38:09', '2025-11-05 23:38:09');

-- ----------------------------
-- Table structure for default_values
-- ----------------------------
DROP TABLE IF EXISTS `default_values`;
CREATE TABLE `default_values`  (
  `id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `table_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `insert_values` json NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of default_values
-- ----------------------------
INSERT INTO `default_values` VALUES ('03289ce5-df6d-4b6f-b453-91ad212a58c7', 'states', '\"{\\\"key\\\":\\\"rejected\\\",\\\"name\\\":\\\"Rejected\\\",\\\"description\\\":\\\"Document has been rejected.\\\",\\\"color\\\":\\\"red\\\",\\\"icon\\\":\\\"rejected-icon.png\\\",\\\"can_edit\\\":false,\\\"can_delete\\\":false,\\\"can_print\\\":false,\\\"is_active\\\":true,\\\"is_default\\\":true}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('0e04f733-7e76-4a01-ae2c-4b4c3c4fb61a', 'modules', '\"{\\\"key\\\":\\\"ap-debit-note\\\",\\\"name\\\":\\\"AP Debit Note\\\",\\\"service_key\\\":\\\"procurement\\\",\\\"group\\\":\\\"account-payable\\\",\\\"default_prefix_code\\\":\\\"DN\\\",\\\"is_active\\\":true,\\\"has_workflow\\\":true,\\\"can_be_deleted\\\":false}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('0e4a1905-8d49-4671-9690-e8d09ec28824', 'tenant_configs', '\"{\\\"config_key\\\":\\\"date_format\\\",\\\"config_value\\\":\\\"Y-m-d\\\",\\\"config_type\\\":\\\"select\\\"}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('134ce936-e9db-4812-886a-57eb01635914', 'states', '\"{\\\"key\\\":\\\"completed\\\",\\\"name\\\":\\\"Completed\\\",\\\"description\\\":\\\"Document processing is completed.\\\",\\\"color\\\":\\\"purple\\\",\\\"icon\\\":\\\"completed-icon.png\\\",\\\"can_edit\\\":false,\\\"can_delete\\\":false,\\\"can_print\\\":true,\\\"is_active\\\":true,\\\"is_default\\\":true}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('13f4f7cd-ec95-4ba7-9bd7-aa8066e21259', 'tenant_configs', '\"{\\\"config_key\\\":\\\"generate_invoice_receipt_by\\\",\\\"config_value\\\":\\\"sales_order_delivery\\\",\\\"config_type\\\":\\\"select\\\"}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('155a861f-67f2-4288-aafe-8a5605a01ecc', 'states', '\"{\\\"key\\\":\\\"unreported\\\",\\\"name\\\":\\\"Unreported\\\",\\\"description\\\":\\\"Document is unreported.\\\",\\\"color\\\":\\\"grey\\\",\\\"icon\\\":\\\"unreported-icon.png\\\",\\\"can_edit\\\":false,\\\"can_delete\\\":false,\\\"can_print\\\":false,\\\"is_active\\\":true,\\\"is_default\\\":true}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('16d12004-3a2e-4977-bcdf-97242a29710d', 'states', '\"{\\\"key\\\":\\\"paid\\\",\\\"name\\\":\\\"Paid\\\",\\\"description\\\":\\\"Document has been paid.\\\",\\\"color\\\":\\\"green\\\",\\\"icon\\\":\\\"paid-icon.png\\\",\\\"can_edit\\\":false,\\\"can_delete\\\":false,\\\"can_print\\\":true,\\\"is_active\\\":true,\\\"is_default\\\":true}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('1992bcc5-b5d4-4b81-9e11-30979b6d9a92', 'states', '\"{\\\"key\\\":\\\"delivered\\\",\\\"name\\\":\\\"Delivered\\\",\\\"description\\\":\\\"Document has been delivered.\\\",\\\"color\\\":\\\"green\\\",\\\"icon\\\":\\\"delivered-icon.png\\\",\\\"can_edit\\\":false,\\\"can_delete\\\":false,\\\"can_print\\\":true,\\\"is_active\\\":true,\\\"is_default\\\":true}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('1a410dfb-e498-478d-997d-3eb623cb3e8b', 'tenant_configs', '\"{\\\"config_key\\\":\\\"currency_format\\\",\\\"config_value\\\":\\\"Rp #,##0\\\",\\\"config_type\\\":\\\"select\\\"}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('1a5a197f-6aed-43c1-8313-6bdcbf98ad21', 'states', '\"{\\\"key\\\":\\\"expired\\\",\\\"name\\\":\\\"Expired\\\",\\\"description\\\":\\\"Document is expired.\\\",\\\"color\\\":\\\"grey\\\",\\\"icon\\\":\\\"expired-icon.png\\\",\\\"can_edit\\\":false,\\\"can_delete\\\":false,\\\"can_print\\\":false,\\\"is_active\\\":true,\\\"is_default\\\":true}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('1fca8249-16bd-45eb-8966-d5e9f48e32aa', 'modules', '\"{\\\"key\\\":\\\"closing-period\\\",\\\"name\\\":\\\"Closing Period\\\",\\\"service_key\\\":\\\"accounting\\\",\\\"group\\\":\\\"accounting\\\",\\\"default_prefix_code\\\":\\\"CLP\\\",\\\"is_active\\\":true,\\\"has_workflow\\\":true,\\\"can_be_deleted\\\":false}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('23732b24-2557-4351-b226-b8e28031d7c7', 'tenant_configs', '\"{\\\"config_key\\\":\\\"auto_generate_invoice_receipt\\\",\\\"config_value\\\":\\\"true\\\",\\\"config_type\\\":\\\"boolean\\\"}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('25ca2f07-3d15-4e7a-87e7-bafd3709284d', 'states', '\"{\\\"key\\\":\\\"open\\\",\\\"name\\\":\\\"Open\\\",\\\"description\\\":\\\"Document is open for editing.\\\",\\\"color\\\":\\\"green\\\",\\\"icon\\\":\\\"open-icon.png\\\",\\\"can_edit\\\":true,\\\"can_delete\\\":false,\\\"can_print\\\":true,\\\"is_active\\\":true,\\\"is_default\\\":true}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('27121362-b2ee-4b43-8ed6-ee65120ada89', 'tenant_configs', '\"{\\\"config_key\\\":\\\"timezone\\\",\\\"config_value\\\":\\\"Asia\\\\/Jakarta\\\",\\\"config_type\\\":\\\"select\\\"}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('284952de-04bf-4739-9b61-cea9dc7cc8cc', 'states', '\"{\\\"key\\\":\\\"disposed\\\",\\\"name\\\":\\\"Disposed\\\",\\\"description\\\":\\\"Document has been disposed.\\\",\\\"color\\\":\\\"grey\\\",\\\"icon\\\":\\\"disposed-icon.png\\\",\\\"can_edit\\\":false,\\\"can_delete\\\":false,\\\"can_print\\\":false,\\\"is_active\\\":true,\\\"is_default\\\":true}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('2945cdd7-e516-482c-b8c9-3b7a118ad57a', 'tenant_configs', '\"{\\\"config_key\\\":\\\"default_vat_percentage\\\",\\\"config_value\\\":\\\"10\\\",\\\"config_type\\\":\\\"number\\\"}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('2b9da810-3231-4bfa-a869-07dc4240058a', 'modules', '\"{\\\"key\\\":\\\"stock-opname\\\",\\\"name\\\":\\\"Stock Opname\\\",\\\"service_key\\\":\\\"management_stock\\\",\\\"group\\\":\\\"management_stock\\\",\\\"default_prefix_code\\\":\\\"BATCH-SO\\\",\\\"is_active\\\":true,\\\"has_workflow\\\":true,\\\"can_be_deleted\\\":false}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('31ad7c98-de03-4b23-9b03-b026f9f272e4', 'states', '\"{\\\"key\\\":\\\"reported\\\",\\\"name\\\":\\\"Reported\\\",\\\"description\\\":\\\"Document is reported.\\\",\\\"color\\\":\\\"grey\\\",\\\"icon\\\":\\\"reversed-icon.png\\\",\\\"can_edit\\\":false,\\\"can_delete\\\":false,\\\"can_print\\\":false,\\\"is_active\\\":true,\\\"is_default\\\":true}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('31be7056-27a4-4436-82de-e9e87e23892a', 'states', '\"{\\\"key\\\":\\\"closed\\\",\\\"name\\\":\\\"Closed\\\",\\\"description\\\":\\\"Document has been closed.\\\",\\\"color\\\":\\\"brown\\\",\\\"icon\\\":\\\"closed-icon.png\\\",\\\"can_edit\\\":false,\\\"can_delete\\\":false,\\\"can_print\\\":true,\\\"is_active\\\":true,\\\"is_default\\\":true}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('31f83b63-2613-4d93-be5b-a20bd7d419d4', 'states', '\"{\\\"key\\\":\\\"partially-received\\\",\\\"name\\\":\\\"Partially Received\\\",\\\"description\\\":\\\"Document has been partially received.\\\",\\\"color\\\":\\\"orange\\\",\\\"icon\\\":\\\"partially-received-icon.png\\\",\\\"can_edit\\\":true,\\\"can_delete\\\":false,\\\"can_print\\\":true,\\\"is_active\\\":true,\\\"is_default\\\":true}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('3283ae58-c52c-46b2-89b1-2d57089d6061', 'states', '\"{\\\"key\\\":\\\"allocated\\\",\\\"name\\\":\\\"Allocated\\\",\\\"description\\\":\\\"Document is allocated.\\\",\\\"color\\\":\\\"grey\\\",\\\"icon\\\":\\\"allocated-icon.png\\\",\\\"can_edit\\\":false,\\\"can_delete\\\":false,\\\"can_print\\\":false,\\\"is_active\\\":true,\\\"is_default\\\":true}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('32f2da79-e378-47fc-a0f9-881f6b9f1bbf', 'states', '\"{\\\"key\\\":\\\"submitted\\\",\\\"name\\\":\\\"Submitted\\\",\\\"description\\\":\\\"Document has been submitted for review.\\\",\\\"color\\\":\\\"blue\\\",\\\"icon\\\":\\\"submitted-icon.png\\\",\\\"can_edit\\\":false,\\\"can_delete\\\":false,\\\"can_print\\\":true,\\\"is_active\\\":true,\\\"is_default\\\":true}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('33e22348-69f3-4591-baae-acbecc3cf252', 'states', '\"{\\\"key\\\":\\\"in-process\\\",\\\"name\\\":\\\"In Process\\\",\\\"description\\\":\\\"Document is currently being processed.\\\",\\\"color\\\":\\\"yellow\\\",\\\"icon\\\":\\\"in-process-icon.png\\\",\\\"can_edit\\\":true,\\\"can_delete\\\":false,\\\"can_print\\\":true,\\\"is_active\\\":true,\\\"is_default\\\":true}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('34357365-2855-471d-889e-332e95034b80', 'states', '\"{\\\"key\\\":\\\"waiting-approval\\\",\\\"name\\\":\\\"Waiting Approval\\\",\\\"description\\\":\\\"Document is waiting for approval.\\\",\\\"color\\\":\\\"blue\\\",\\\"icon\\\":\\\"waiting-approval-icon.png\\\",\\\"can_edit\\\":false,\\\"can_delete\\\":false,\\\"can_print\\\":false,\\\"is_active\\\":true,\\\"is_default\\\":true}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('3643d046-c524-4b56-b99a-e2d8db6b9f98', 'states', '\"{\\\"key\\\":\\\"expired\\\",\\\"name\\\":\\\"Expired\\\",\\\"description\\\":\\\"Document has expired.\\\",\\\"color\\\":\\\"grey\\\",\\\"icon\\\":\\\"expired-icon.png\\\",\\\"can_edit\\\":false,\\\"can_delete\\\":false,\\\"can_print\\\":false,\\\"is_active\\\":true,\\\"is_default\\\":true}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('3ad1d0b8-ba69-461e-924f-f1e2864226ee', 'modules', '\"{\\\"key\\\":\\\"stock-consume\\\",\\\"name\\\":\\\"Stock Consume\\\",\\\"service_key\\\":\\\"management_stock\\\",\\\"group\\\":\\\"management_stock\\\",\\\"default_prefix_code\\\":\\\"BATCH-CS\\\",\\\"is_active\\\":true,\\\"has_workflow\\\":true,\\\"can_be_deleted\\\":false}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('3c412861-c761-4bb3-b66e-a0bd0ed4c4e2', 'states', '\"{\\\"key\\\":\\\"in-review\\\",\\\"name\\\":\\\"In Review\\\",\\\"description\\\":\\\"Document is under review.\\\",\\\"color\\\":\\\"teal\\\",\\\"icon\\\":\\\"in-review-icon.png\\\",\\\"can_edit\\\":false,\\\"can_delete\\\":false,\\\"can_print\\\":false,\\\"is_active\\\":true,\\\"is_default\\\":true}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('3e444f07-bfe3-4e7e-a570-458965e7d5eb', 'states', '\"{\\\"key\\\":\\\"waiting-payment\\\",\\\"name\\\":\\\"Waiting Payment\\\",\\\"description\\\":\\\"Document is waiting for payment.\\\",\\\"color\\\":\\\"yellow\\\",\\\"icon\\\":\\\"waiting-payment-icon.png\\\",\\\"can_edit\\\":false,\\\"can_delete\\\":false,\\\"can_print\\\":false,\\\"is_active\\\":true,\\\"is_default\\\":true}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('404a669d-8ed3-4e72-9122-d5e2dfd9047c', 'user_configs', '\"{\\\"config_key\\\":\\\"content_width\\\",\\\"config_value\\\":\\\"full\\\",\\\"config_type\\\":\\\"string\\\"}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('41e22e2a-f63b-476a-9743-010e6f5aed61', 'states', '\"{\\\"key\\\":\\\"draft\\\",\\\"name\\\":\\\"Draft\\\",\\\"description\\\":\\\"Initial state of the document.\\\",\\\"color\\\":\\\"grey\\\",\\\"icon\\\":\\\"draft-icon.png\\\",\\\"can_edit\\\":true,\\\"can_delete\\\":true,\\\"can_print\\\":false,\\\"is_active\\\":true,\\\"is_default\\\":true}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('41ee5218-356f-4b11-ad89-0d9686c6732d', 'states', '\"{\\\"key\\\":\\\"repacked\\\",\\\"name\\\":\\\"Repacked\\\",\\\"description\\\":\\\"Document has been repacked.\\\",\\\"color\\\":\\\"grey\\\",\\\"icon\\\":\\\"repacked-icon.png\\\",\\\"can_edit\\\":false,\\\"can_delete\\\":false,\\\"can_print\\\":false,\\\"is_active\\\":true,\\\"is_default\\\":true}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('41fba732-6d82-48b7-b7b0-225c9b972555', 'modules', '\"{\\\"key\\\":\\\"stock-transfer\\\",\\\"name\\\":\\\"Stock Transfer\\\",\\\"service_key\\\":\\\"management_stock\\\",\\\"group\\\":\\\"management_stock\\\",\\\"default_prefix_code\\\":\\\"BATCH-ST\\\",\\\"is_active\\\":true,\\\"has_workflow\\\":true,\\\"can_be_deleted\\\":false}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('456b21cf-bd72-4231-98bb-aae10e3e5a76', 'modules', '\"{\\\"key\\\":\\\"journal-entry\\\",\\\"name\\\":\\\"Journal Entry\\\",\\\"service_key\\\":\\\"accounting\\\",\\\"group\\\":\\\"accounting\\\",\\\"default_prefix_code\\\":\\\"JRN\\\",\\\"is_active\\\":true,\\\"has_workflow\\\":true,\\\"can_be_deleted\\\":false}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('45b348fb-b020-4ec3-bcdc-2960134dda8a', 'modules', '\"{\\\"key\\\":\\\"salesorder\\\",\\\"name\\\":\\\"Sales Order\\\",\\\"service_key\\\":\\\"salesorder\\\",\\\"group\\\":\\\"salesorder\\\",\\\"default_prefix_code\\\":\\\"SO\\\",\\\"is_active\\\":true,\\\"has_workflow\\\":true,\\\"can_be_deleted\\\":false}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('478338a8-dd43-4221-83f4-5019c9f8745c', 'modules', '\"{\\\"key\\\":\\\"stock-disposal\\\",\\\"name\\\":\\\"Stock Disposal\\\",\\\"service_key\\\":\\\"management_stock\\\",\\\"group\\\":\\\"management_stock\\\",\\\"default_prefix_code\\\":\\\"BATCH-DS\\\",\\\"is_active\\\":true,\\\"has_workflow\\\":true,\\\"can_be_deleted\\\":false}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('4f5279a8-1984-4385-b40b-04004efe5d0e', 'states', '\"{\\\"key\\\":\\\"exceeded\\\",\\\"name\\\":\\\"Exceeded\\\",\\\"description\\\":\\\"Document is exceeded.\\\",\\\"color\\\":\\\"grey\\\",\\\"icon\\\":\\\"exceeded-icon.png\\\",\\\"can_edit\\\":false,\\\"can_delete\\\":false,\\\"can_print\\\":false,\\\"is_active\\\":true,\\\"is_default\\\":true}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('517c28f6-33d3-4096-8682-93df37a7314b', 'states', '\"{\\\"key\\\":\\\"in-order\\\",\\\"name\\\":\\\"In Order\\\",\\\"description\\\":\\\"Document is in order for processing.\\\",\\\"color\\\":\\\"blue\\\",\\\"icon\\\":\\\"in-order-icon.png\\\",\\\"can_edit\\\":true,\\\"can_delete\\\":false,\\\"can_print\\\":true,\\\"is_active\\\":true,\\\"is_default\\\":true}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('521531a7-5d2b-4540-9e73-8458f586bbff', 'user_configs', '\"{\\\"config_key\\\":\\\"email_notifications\\\",\\\"config_value\\\":\\\"true\\\",\\\"config_type\\\":\\\"boolean\\\"}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('5a41fe83-8e4e-4321-8c33-999a4c55dbf4', 'modules', '\"{\\\"key\\\":\\\"goods-receipt\\\",\\\"name\\\":\\\"Goods Receipt\\\",\\\"service_key\\\":\\\"procurement\\\",\\\"group\\\":\\\"procurement\\\",\\\"default_prefix_code\\\":\\\"GR\\\",\\\"is_active\\\":true,\\\"has_workflow\\\":true,\\\"can_be_deleted\\\":false}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('5c398d19-907a-45b2-a37d-19e99e0537cd', 'modules', '\"{\\\"key\\\":\\\"purchase-return\\\",\\\"name\\\":\\\"Purchase Return Vendor\\\",\\\"service_key\\\":\\\"procurement\\\",\\\"group\\\":\\\"procurement\\\",\\\"default_prefix_code\\\":\\\"RTV\\\",\\\"is_active\\\":true,\\\"has_workflow\\\":true,\\\"can_be_deleted\\\":false}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('5e7607c6-13c6-4c02-9004-2aeab9243699', 'user_configs', '\"{\\\"config_key\\\":\\\"language\\\",\\\"config_value\\\":\\\"id\\\",\\\"config_type\\\":\\\"string\\\"}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('5eb3c848-8761-4882-bdeb-4176adf6595a', 'modules', '\"{\\\"key\\\":\\\"ap-invoice\\\",\\\"name\\\":\\\"AP Invoice\\\",\\\"service_key\\\":\\\"procurement\\\",\\\"group\\\":\\\"account-payable\\\",\\\"default_prefix_code\\\":\\\"AP-INV\\\",\\\"is_active\\\":true,\\\"has_workflow\\\":true,\\\"can_be_deleted\\\":false}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('6447138b-7a1d-45c8-8914-882021b15b68', 'modules', '\"{\\\"key\\\":\\\"ar-credit-note\\\",\\\"name\\\":\\\"Accounts Receivable Credit Note\\\",\\\"service_key\\\":\\\"salesorder\\\",\\\"group\\\":\\\"account-receivable\\\",\\\"default_prefix_code\\\":\\\"CN\\\",\\\"is_active\\\":true,\\\"has_workflow\\\":true,\\\"can_be_deleted\\\":false}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('6b4072ef-9e10-48e1-8d20-5245dc240a18', 'modules', '\"{\\\"key\\\":\\\"accounting_manual_expense\\\",\\\"name\\\":\\\"Manual Expense\\\",\\\"service_key\\\":\\\"accounting\\\",\\\"group_key\\\":\\\"accounting\\\",\\\"default_prefix_code\\\":\\\"MEXP\\\",\\\"has_workflow\\\":true,\\\"is_active\\\":true,\\\"can_be_deleted\\\":false,\\\"created_at\\\":\\\"2025-11-05T16:38:09.571461Z\\\",\\\"updated_at\\\":\\\"2025-11-05T16:38:09.571466Z\\\"}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('6d66db82-ba4b-481d-b840-2dd94178c92d', 'states', '\"{\\\"key\\\":\\\"returned\\\",\\\"name\\\":\\\"Returned\\\",\\\"description\\\":\\\"Document has been returned.\\\",\\\"color\\\":\\\"orange\\\",\\\"icon\\\":\\\"returned-icon.png\\\",\\\"can_edit\\\":false,\\\"can_delete\\\":false,\\\"can_print\\\":true,\\\"is_active\\\":true,\\\"is_default\\\":true}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('7216a496-c3ec-42c7-847e-a730a2568d08', 'modules', '\"{\\\"key\\\":\\\"fund-settlement\\\",\\\"name\\\":\\\"Fund Settlement\\\",\\\"service_key\\\":\\\"finance\\\",\\\"group\\\":\\\"finance\\\",\\\"default_prefix_code\\\":\\\"FST\\\",\\\"is_active\\\":true,\\\"has_workflow\\\":true,\\\"can_be_deleted\\\":false}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('726e74ed-d696-488d-baa9-cdfecb83af13', 'modules', '\"{\\\"key\\\":\\\"cashflow-projection\\\",\\\"name\\\":\\\"Cashflow Projection\\\",\\\"service_key\\\":\\\"finance\\\",\\\"group\\\":\\\"finance\\\",\\\"default_prefix_code\\\":\\\"CFP\\\",\\\"is_active\\\":true,\\\"has_workflow\\\":true,\\\"can_be_deleted\\\":false}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('73cf2a8f-2c7f-4ded-be30-c172699af1a9', 'user_configs', '\"{\\\"config_key\\\":\\\"rtl\\\",\\\"config_value\\\":\\\"false\\\",\\\"config_type\\\":\\\"boolean\\\"}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('74d7c7f7-785e-4745-9d5c-b4b88eb2300f', 'tenant_configs', '\"{\\\"config_key\\\":\\\"margin_percentage\\\",\\\"config_value\\\":\\\"true\\\",\\\"config_type\\\":\\\"boolean\\\"}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('7778e786-c026-479f-88a2-4238f7cfa9be', 'modules', '\"{\\\"key\\\":\\\"stock-repack\\\",\\\"name\\\":\\\"Stock Repack\\\",\\\"service_key\\\":\\\"management_stock\\\",\\\"group\\\":\\\"management_stock\\\",\\\"default_prefix_code\\\":\\\"BATCH-RP\\\",\\\"is_active\\\":true,\\\"has_workflow\\\":true,\\\"can_be_deleted\\\":false}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('79c99a59-ac29-4e71-974d-b4ddb8683714', 'tenant_configs', '\"{\\\"config_key\\\":\\\"accounting_fiscal_year_start\\\",\\\"config_value\\\":\\\"2025-01\\\",\\\"config_type\\\":\\\"string\\\"}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('7a135c08-9cfa-45b2-8b17-aa799a97a277', 'modules', '\"{\\\"key\\\":\\\"ar-deposit\\\",\\\"name\\\":\\\"Accounts Receivable Deposit\\\",\\\"service_key\\\":\\\"salesorder\\\",\\\"group\\\":\\\"account-receivable\\\",\\\"default_prefix_code\\\":\\\"AR-DEP\\\",\\\"is_active\\\":true,\\\"has_workflow\\\":true,\\\"can_be_deleted\\\":false}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('7a18f91b-c1c0-4b32-b83e-b3e8b0df7082', 'tenant_configs', '\"{\\\"config_key\\\":\\\"minimum_stock_alert\\\",\\\"config_value\\\":\\\"true\\\",\\\"config_type\\\":\\\"boolean\\\"}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('7a666827-6655-4529-b417-820723e3c1b3', 'modules', '\"{\\\"key\\\":\\\"fund-request\\\",\\\"name\\\":\\\"Fund Request (Cash Advance)\\\",\\\"service_key\\\":\\\"finance\\\",\\\"group\\\":\\\"finance\\\",\\\"default_prefix_code\\\":\\\"FRQ\\\",\\\"is_active\\\":true,\\\"has_workflow\\\":true,\\\"can_be_deleted\\\":false}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('7aa6d179-2c4e-49d7-a1f9-542627d44d1d', 'states', '\"{\\\"key\\\":\\\"approved\\\",\\\"name\\\":\\\"Approved\\\",\\\"description\\\":\\\"Document has been approved.\\\",\\\"color\\\":\\\"green\\\",\\\"icon\\\":\\\"approved-icon.png\\\",\\\"can_edit\\\":false,\\\"can_delete\\\":false,\\\"can_print\\\":true,\\\"is_active\\\":true,\\\"is_default\\\":true}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('7aef4c80-f42d-4372-96f7-5cf0a18f2888', 'states', '\"{\\\"key\\\":\\\"success\\\",\\\"name\\\":\\\"Success\\\",\\\"description\\\":\\\"Document processed successfully.\\\",\\\"color\\\":\\\"green\\\",\\\"icon\\\":\\\"success-icon.png\\\",\\\"can_edit\\\":false,\\\"can_delete\\\":false,\\\"can_print\\\":true,\\\"is_active\\\":true,\\\"is_default\\\":true}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('83e78076-5174-46d5-9b4b-e0dbf880f9a1', 'modules', '\"{\\\"key\\\":\\\"ap-payment\\\",\\\"name\\\":\\\"AP Payment\\\",\\\"service_key\\\":\\\"procurement\\\",\\\"group\\\":\\\"account-payable\\\",\\\"default_prefix_code\\\":\\\"AP-PAY\\\",\\\"is_active\\\":true,\\\"has_workflow\\\":true,\\\"can_be_deleted\\\":false}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('88e6674c-6a35-4792-b1c0-2a3410507bb6', 'modules', '\"{\\\"key\\\":\\\"salesorder-return-customer\\\",\\\"name\\\":\\\"Sales Order Return Customer\\\",\\\"service_key\\\":\\\"salesorder\\\",\\\"group\\\":\\\"salesorder\\\",\\\"default_prefix_code\\\":\\\"RTC\\\",\\\"is_active\\\":true,\\\"has_workflow\\\":true,\\\"can_be_deleted\\\":false}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('8a895911-898e-416b-aea2-ca2e1fe39dc5', 'modules', '\"{\\\"key\\\":\\\"budget-revision\\\",\\\"name\\\":\\\"Budget Revision\\\",\\\"service_key\\\":\\\"finance\\\",\\\"group\\\":\\\"finance\\\",\\\"default_prefix_code\\\":\\\"BUDG-REV\\\",\\\"is_active\\\":true,\\\"has_workflow\\\":true,\\\"can_be_deleted\\\":false}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('8c4dd2fb-4bb2-4dac-b3ad-056dae83ffed', 'states', '\"{\\\"key\\\":\\\"failed\\\",\\\"name\\\":\\\"Failed\\\",\\\"description\\\":\\\"Document processing failed.\\\",\\\"color\\\":\\\"red\\\",\\\"icon\\\":\\\"failed-icon.png\\\",\\\"can_edit\\\":false,\\\"can_delete\\\":false,\\\"can_print\\\":false,\\\"is_active\\\":true,\\\"is_default\\\":true}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('8cd2cb5f-34d1-4004-8efe-f4c0595e7cd2', 'tenant_configs', '\"{\\\"config_key\\\":\\\"default_language\\\",\\\"config_value\\\":\\\"id\\\",\\\"config_type\\\":\\\"select\\\"}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('8e5b18f7-417d-4e7a-bd79-ab7abd474575', 'tenant_configs', '\"{\\\"config_key\\\":\\\"accounting_fiscal_year_start\\\",\\\"config_value\\\":\\\"2025-01\\\",\\\"config_type\\\":\\\"string\\\"}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('8eefae79-7a5b-4ffa-a7c4-9e35d4989d49', 'modules', '\"{\\\"key\\\":\\\"chart-of-account\\\",\\\"name\\\":\\\"Chart of Account\\\",\\\"service_key\\\":\\\"accounting\\\",\\\"group\\\":\\\"accounting\\\",\\\"default_prefix_code\\\":\\\"COA\\\",\\\"is_active\\\":true,\\\"has_workflow\\\":false,\\\"can_be_deleted\\\":false}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('904a871e-6938-47a6-a920-7970c48d390e', 'modules', '\"{\\\"key\\\":\\\"stock-batch-management\\\",\\\"name\\\":\\\"Stock Batch Management\\\",\\\"service_key\\\":\\\"management_stock\\\",\\\"group\\\":\\\"management_stock\\\",\\\"default_prefix_code\\\":\\\"BATCH\\\",\\\"is_active\\\":true,\\\"has_workflow\\\":false,\\\"can_be_deleted\\\":false}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('90e1bb78-afbe-4ea5-827a-daaaa1f43132', 'modules', '\"{\\\"key\\\":\\\"stock-adjustment\\\",\\\"name\\\":\\\"Stock Adjustment\\\",\\\"service_key\\\":\\\"management_stock\\\",\\\"group\\\":\\\"management_stock\\\",\\\"default_prefix_code\\\":\\\"BATCH-SA\\\",\\\"is_active\\\":true,\\\"has_workflow\\\":true,\\\"can_be_deleted\\\":false}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('92c83251-11f3-4235-b09b-4f6dee85a119', 'states', '\"{\\\"key\\\":\\\"pending\\\",\\\"name\\\":\\\"Pending\\\",\\\"description\\\":\\\"Document is pending review.\\\",\\\"color\\\":\\\"red\\\",\\\"icon\\\":\\\"pending-icon.png\\\",\\\"can_edit\\\":true,\\\"can_delete\\\":false,\\\"can_print\\\":true,\\\"is_active\\\":true,\\\"is_default\\\":true}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('93d54f2e-4908-4026-b250-593a4aa90fb5', 'user_configs', '\"{\\\"config_key\\\":\\\"menu_layout\\\",\\\"config_value\\\":\\\"vertical\\\",\\\"config_type\\\":\\\"string\\\"}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('945cd91c-1651-456c-9610-babe89e2280b', 'states', '\"{\\\"key\\\":\\\"archived\\\",\\\"name\\\":\\\"Archived\\\",\\\"description\\\":\\\"Document has been archived.\\\",\\\"color\\\":\\\"brown\\\",\\\"icon\\\":\\\"archived-icon.png\\\",\\\"can_edit\\\":false,\\\"can_delete\\\":false,\\\"can_print\\\":true,\\\"is_active\\\":true,\\\"is_default\\\":true}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('953543a0-97c6-40ad-978b-4d4786ecbb71', 'states', '\"{\\\"key\\\":\\\"planned\\\",\\\"name\\\":\\\"Planned\\\",\\\"description\\\":\\\"Document is planned.\\\",\\\"color\\\":\\\"grey\\\",\\\"icon\\\":\\\"planned-icon.png\\\",\\\"can_edit\\\":false,\\\"can_delete\\\":false,\\\"can_print\\\":false,\\\"is_active\\\":true,\\\"is_default\\\":true}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('969da7c1-14e8-4abe-ab82-017a36736545', 'modules', '\"{\\\"key\\\":\\\"delivery-order\\\",\\\"name\\\":\\\"Delivery Order\\\",\\\"service_key\\\":\\\"management_stock\\\",\\\"group\\\":\\\"management_stock\\\",\\\"default_prefix_code\\\":\\\"DO\\\",\\\"is_active\\\":true,\\\"has_workflow\\\":true,\\\"can_be_deleted\\\":false}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('97bc396a-2c14-4ea7-a236-0e134de25ba2', 'modules', '\"{\\\"key\\\":\\\"salesorder-request\\\",\\\"name\\\":\\\"Sales Order Request\\\",\\\"service_key\\\":\\\"salesorder\\\",\\\"group\\\":\\\"salesorder\\\",\\\"default_prefix_code\\\":\\\"SO-REQ\\\",\\\"is_active\\\":true,\\\"has_workflow\\\":true,\\\"can_be_deleted\\\":false}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('a130b18e-c360-4143-80ed-b98182c87da4', 'modules', '\"{\\\"key\\\":\\\"purchase-order\\\",\\\"name\\\":\\\"Purchase Order\\\",\\\"service_key\\\":\\\"procurement\\\",\\\"group\\\":\\\"procurement\\\",\\\"default_prefix_code\\\":\\\"PO\\\",\\\"is_active\\\":true,\\\"has_workflow\\\":true,\\\"can_be_deleted\\\":false}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('a297f97c-7770-4fe9-b046-5745bf965d12', 'states', '\"{\\\"key\\\":\\\"moved\\\",\\\"name\\\":\\\"Moved\\\",\\\"description\\\":\\\"Document has been moved.\\\",\\\"color\\\":\\\"grey\\\",\\\"icon\\\":\\\"moved-icon.png\\\",\\\"can_edit\\\":false,\\\"can_delete\\\":false,\\\"can_print\\\":false,\\\"is_active\\\":true,\\\"is_default\\\":true}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('a29850ff-ec48-4930-8aee-3976e9eada1f', 'tenant_configs', '\"{\\\"config_key\\\":\\\"item_auto_generate_code\\\",\\\"config_value\\\":\\\"true\\\",\\\"config_type\\\":\\\"boolean\\\"}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('a4300095-1481-4a71-b3b5-2dc2fd391560', 'modules', '\"{\\\"key\\\":\\\"ar-invoice\\\",\\\"name\\\":\\\"Accounts Receivable Invoice\\\",\\\"service_key\\\":\\\"salesorder\\\",\\\"group\\\":\\\"account-receivable\\\",\\\"default_prefix_code\\\":\\\"AR-PAY\\\",\\\"is_active\\\":true,\\\"has_workflow\\\":true,\\\"can_be_deleted\\\":false}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('a89efbf2-f1c3-463b-ae3f-865997ba83d8', 'tenant_configs', '\"{\\\"config_key\\\":\\\"enable_minimum_margin\\\",\\\"config_value\\\":\\\"true\\\",\\\"config_type\\\":\\\"boolean\\\"}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('b2634145-ac54-4ffb-a228-ac1002292b18', 'modules', '\"{\\\"key\\\":\\\"ar-allocation\\\",\\\"name\\\":\\\"Accounts Receivable Allocation\\\",\\\"service_key\\\":\\\"salesorder\\\",\\\"group\\\":\\\"account-receivable\\\",\\\"default_prefix_code\\\":\\\"AR-ALC\\\",\\\"is_active\\\":true,\\\"has_workflow\\\":true,\\\"can_be_deleted\\\":false}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('b5a114fc-7b6a-464c-bd80-109cbdadb5fc', 'states', '\"{\\\"key\\\":\\\"partial-payment\\\",\\\"name\\\":\\\"Partial Payment\\\",\\\"description\\\":\\\"Document has been partially paid.\\\",\\\"color\\\":\\\"orange\\\",\\\"icon\\\":\\\"partial-payment-icon.png\\\",\\\"can_edit\\\":false,\\\"can_delete\\\":false,\\\"can_print\\\":true,\\\"is_active\\\":true,\\\"is_default\\\":true}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('bbc65910-9827-4bb0-ac15-ec62cd618343', 'states', '\"{\\\"key\\\":\\\"on-hold\\\",\\\"name\\\":\\\"On Hold\\\",\\\"description\\\":\\\"Document is currently on hold.\\\",\\\"color\\\":\\\"orange\\\",\\\"icon\\\":\\\"on-hold-icon.png\\\",\\\"can_edit\\\":false,\\\"can_delete\\\":false,\\\"can_print\\\":false,\\\"is_active\\\":true,\\\"is_default\\\":true}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('bdd1b72c-c5ca-4810-a337-df70685d8e1f', 'modules', '\"{\\\"key\\\":\\\"ap-allocation\\\",\\\"name\\\":\\\"AP Allocation\\\",\\\"service_key\\\":\\\"procurement\\\",\\\"group\\\":\\\"account-payable\\\",\\\"default_prefix_code\\\":\\\"AP-ALC\\\",\\\"is_active\\\":true,\\\"has_workflow\\\":true,\\\"can_be_deleted\\\":false}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('c16c9975-4fca-4bbf-ad61-87c5f1e059ef', 'tenant_configs', '\"{\\\"config_key\\\":\\\"generate_invoice_payment_by\\\",\\\"config_value\\\":\\\"purchase_receipt\\\",\\\"config_type\\\":\\\"select\\\"}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('c528fc7c-419c-407e-a31e-c4f4b47e8808', 'user_configs', '\"{\\\"config_key\\\":\\\"dark_mode\\\",\\\"config_value\\\":\\\"by_system\\\",\\\"config_type\\\":\\\"string\\\"}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('c73d2714-df28-4dd2-b0ba-b2c6b02bec89', 'tenant_configs', '\"{\\\"config_key\\\":\\\"available_vat\\\",\\\"config_value\\\":\\\"true\\\",\\\"config_type\\\":\\\"boolean\\\"}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('c79466fb-7d4b-45a4-af23-fdfbc5d4b1f4', 'modules', '\"{\\\"key\\\":\\\"trial-balance\\\",\\\"name\\\":\\\"Trial Balance\\\",\\\"service_key\\\":\\\"accounting\\\",\\\"group\\\":\\\"accounting\\\",\\\"default_prefix_code\\\":\\\"TB\\\",\\\"is_active\\\":true,\\\"has_workflow\\\":false,\\\"can_be_deleted\\\":false}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('c7ee201a-c0be-4847-9540-9602e1a4413d', 'tenant_configs', '\"{\\\"config_key\\\":\\\"main_currency\\\",\\\"config_value\\\":\\\"IDR\\\",\\\"config_type\\\":\\\"string\\\"}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('d2cb233c-d659-417a-914f-dcfca80fd3ad', 'modules', '\"{\\\"key\\\":\\\"fixed-asset-register\\\",\\\"name\\\":\\\"Fixed Asset Register\\\",\\\"service_key\\\":\\\"accounting\\\",\\\"group\\\":\\\"accounting\\\",\\\"default_prefix_code\\\":\\\"FA\\\",\\\"is_active\\\":true,\\\"has_workflow\\\":true,\\\"can_be_deleted\\\":false}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('d612f6b2-575c-4315-ac2b-b8696ce3bc4c', 'states', '\"{\\\"key\\\":\\\"cancelled\\\",\\\"name\\\":\\\"Cancelled\\\",\\\"description\\\":\\\"Document has been cancelled.\\\",\\\"color\\\":\\\"black\\\",\\\"icon\\\":\\\"cancelled-icon.png\\\",\\\"can_edit\\\":false,\\\"can_delete\\\":false,\\\"can_print\\\":false,\\\"is_active\\\":true,\\\"is_default\\\":true}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('db44c3c1-2181-40b8-99b6-9e7d0fdadb9c', 'modules', '\"{\\\"key\\\":\\\"procurement-request\\\",\\\"name\\\":\\\"Procurement Request\\\",\\\"service_key\\\":\\\"procurement\\\",\\\"group\\\":\\\"procurement\\\",\\\"default_prefix_code\\\":\\\"PR\\\",\\\"is_active\\\":true,\\\"has_workflow\\\":true,\\\"can_be_deleted\\\":false}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('dce91de4-f573-42e5-9296-b8581c68ff96', 'tenant_configs', '\"{\\\"config_key\\\":\\\"auto_generate_invoice_payment\\\",\\\"config_value\\\":\\\"true\\\",\\\"config_type\\\":\\\"boolean\\\"}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('de7a95e8-2813-475d-bed1-26ef44ce5b84', 'modules', '\"{\\\"key\\\":\\\"budget-plan\\\",\\\"name\\\":\\\"Budget Plan\\\",\\\"service_key\\\":\\\"finance\\\",\\\"group\\\":\\\"finance\\\",\\\"default_prefix_code\\\":\\\"BUDG\\\",\\\"is_active\\\":true,\\\"has_workflow\\\":true,\\\"can_be_deleted\\\":false}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('e283e055-f7a7-4774-b540-1831412fff5b', 'states', '\"{\\\"key\\\":\\\"partial\\\",\\\"name\\\":\\\"Partial\\\",\\\"description\\\":\\\"Document is partially processed.\\\",\\\"color\\\":\\\"orange\\\",\\\"icon\\\":\\\"partial-icon.png\\\",\\\"can_edit\\\":true,\\\"can_delete\\\":false,\\\"can_print\\\":true,\\\"is_active\\\":true,\\\"is_default\\\":true}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('e61603d0-840b-48f8-8044-bf47ed65a1a9', 'states', '\"{\\\"key\\\":\\\"posted\\\",\\\"name\\\":\\\"Posted\\\",\\\"description\\\":\\\"Document is posted.\\\",\\\"color\\\":\\\"grey\\\",\\\"icon\\\":\\\"posted-icon.png\\\",\\\"can_edit\\\":false,\\\"can_delete\\\":false,\\\"can_print\\\":false,\\\"is_active\\\":true,\\\"is_default\\\":true}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('e64563fe-d44b-4698-bafc-8467fd77dcbb', 'states', '\"{\\\"key\\\":\\\"processing\\\",\\\"name\\\":\\\"Processing\\\",\\\"description\\\":\\\"Document is being processed.\\\",\\\"color\\\":\\\"blue\\\",\\\"icon\\\":\\\"processing-icon.png\\\",\\\"can_edit\\\":false,\\\"can_delete\\\":false,\\\"can_print\\\":false,\\\"is_active\\\":true,\\\"is_default\\\":true}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('ef93a835-7fb6-46a0-a2f5-1767250bd0c9', 'modules', '\"{\\\"key\\\":\\\"general-ledger\\\",\\\"name\\\":\\\"General Ledger\\\",\\\"service_key\\\":\\\"accounting\\\",\\\"group\\\":\\\"accounting\\\",\\\"default_prefix_code\\\":\\\"GL\\\",\\\"is_active\\\":true,\\\"has_workflow\\\":false,\\\"can_be_deleted\\\":false}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('f46ffdae-e558-4e94-b1b9-f5c2274f3514', 'modules', '\"{\\\"key\\\":\\\"accounting_manual_income\\\",\\\"name\\\":\\\"Manual Income\\\",\\\"service_key\\\":\\\"accounting\\\",\\\"group_key\\\":\\\"accounting\\\",\\\"default_prefix_code\\\":\\\"MINC\\\",\\\"has_workflow\\\":true,\\\"is_active\\\":true,\\\"can_be_deleted\\\":false,\\\"created_at\\\":\\\"2025-11-05T16:38:09.570868Z\\\",\\\"updated_at\\\":\\\"2025-11-05T16:38:09.570876Z\\\"}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('f56ae18f-8af1-49e7-95b4-5a8e7eb4992b', 'states', '\"{\\\"key\\\":\\\"closed\\\",\\\"name\\\":\\\"Closed\\\",\\\"description\\\":\\\"Document has been closed.\\\",\\\"color\\\":\\\"brown\\\",\\\"icon\\\":\\\"closed-icon.png\\\",\\\"can_edit\\\":false,\\\"can_delete\\\":false,\\\"can_print\\\":true,\\\"is_active\\\":true,\\\"is_default\\\":true}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('f6161ec1-b29a-462c-9a15-4b9da4110c5e', 'states', '\"{\\\"key\\\":\\\"unpaid\\\",\\\"name\\\":\\\"Unpaid\\\",\\\"description\\\":\\\"Document has not been paid.\\\",\\\"color\\\":\\\"red\\\",\\\"icon\\\":\\\"unpaid-icon.png\\\",\\\"can_edit\\\":false,\\\"can_delete\\\":false,\\\"can_print\\\":false,\\\"is_active\\\":true,\\\"is_default\\\":true}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('fdeff9c9-3092-4dc9-9949-df9a762f9c66', 'states', '\"{\\\"key\\\":\\\"partial-payment\\\",\\\"name\\\":\\\"Partial Payment\\\",\\\"description\\\":\\\"Document has been partially paid.\\\",\\\"color\\\":\\\"grey\\\",\\\"icon\\\":\\\"partial-payment-icon.png\\\",\\\"can_edit\\\":false,\\\"can_delete\\\":false,\\\"can_print\\\":false,\\\"is_active\\\":true,\\\"is_default\\\":true}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('ff152ae1-3646-4f75-a26c-8bdb0305164c', 'states', '\"{\\\"key\\\":\\\"reversed\\\",\\\"name\\\":\\\"Reversed\\\",\\\"description\\\":\\\"Document is reversed.\\\",\\\"color\\\":\\\"grey\\\",\\\"icon\\\":\\\"reversed-icon.png\\\",\\\"can_edit\\\":false,\\\"can_delete\\\":false,\\\"can_print\\\":false,\\\"is_active\\\":true,\\\"is_default\\\":true}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `default_values` VALUES ('ff1ebfc3-ccb4-484c-9b07-3bb6c6aa58e1', 'states', '\"{\\\"key\\\":\\\"void\\\",\\\"name\\\":\\\"Void\\\",\\\"description\\\":\\\"Document has been voided.\\\",\\\"color\\\":\\\"grey\\\",\\\"icon\\\":\\\"void-icon.png\\\",\\\"can_edit\\\":false,\\\"can_delete\\\":false,\\\"can_print\\\":false,\\\"is_active\\\":true,\\\"is_default\\\":true}\"', '2025-11-05 23:38:09', '2025-11-05 23:38:09');

-- ----------------------------
-- Table structure for email_verification_tokens
-- ----------------------------
DROP TABLE IF EXISTS `email_verification_tokens`;
CREATE TABLE `email_verification_tokens`  (
  `email` varchar(191) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `expires_at` timestamp NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`email`) USING BTREE,
  INDEX `idx_token`(`token` ASC) USING BTREE,
  INDEX `idx_expires_at`(`expires_at` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of email_verification_tokens
-- ----------------------------

-- ----------------------------
-- Table structure for failed_login_attempts
-- ----------------------------
DROP TABLE IF EXISTS `failed_login_attempts`;
CREATE TABLE `failed_login_attempts`  (
  `id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `user_agent` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `attempted_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `latitude` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `longitude` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of failed_login_attempts
-- ----------------------------
INSERT INTO `failed_login_attempts` VALUES ('53133e37-785a-4541-8e11-f3a176151a3d', '790de8f0-0574-4d28-bd62-d04d4a85b793', '127.0.0.1', 'Apidog/1.0.0 (https://apidog.com)', '{\"usernameOrEmail\":\"superadmin\",\"url\":\"/api/v1/auth/login\",\"method\":\"POST\"}', '2025-11-11 16:37:14', NULL, NULL);
INSERT INTO `failed_login_attempts` VALUES ('64d486a1-0b47-429a-b34a-e94dd80daca0', '790de8f0-0574-4d28-bd62-d04d4a85b793', '127.0.0.1', 'Mozilla/5.0 (iPhone; CPU iPhone OS 18_5 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/18.5 Mobile/15E148 Safari/604.1', '{\"usernameOrEmail\":\"superadmin\",\"url\":\"/api/v1/auth/login\",\"method\":\"POST\"}', '2025-11-11 17:40:25', NULL, NULL);
INSERT INTO `failed_login_attempts` VALUES ('6d7dd946-81ab-418f-a7bd-4cc536fc8264', '790de8f0-0574-4d28-bd62-d04d4a85b793', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', '{\"usernameOrEmail\":\"superadmin\",\"url\":\"/api/v1/auth/login\",\"method\":\"POST\"}', '2025-11-11 17:48:27', NULL, NULL);

-- ----------------------------
-- Table structure for password_reset_tokens
-- ----------------------------
DROP TABLE IF EXISTS `password_reset_tokens`;
CREATE TABLE `password_reset_tokens`  (
  `email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `token` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `expires_at` timestamp NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`email`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of password_reset_tokens
-- ----------------------------

-- ----------------------------
-- Table structure for refresh_tokens
-- ----------------------------
DROP TABLE IF EXISTS `refresh_tokens`;
CREATE TABLE `refresh_tokens`  (
  `id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `session_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `token_hash` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `expires_at` timestamp NOT NULL,
  `revoked` tinyint(1) NOT NULL DEFAULT 0,
  `revoked_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `refresh_tokens_token_unique`(`token_hash` ASC) USING BTREE,
  INDEX `refresh_tokens_user_id_foreign`(`user_id` ASC) USING BTREE,
  CONSTRAINT `refresh_tokens_user_id_foreign` FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of refresh_tokens
-- ----------------------------
INSERT INTO `refresh_tokens` VALUES ('00a3a079-2bb9-433f-98ae-c9b3b9dfee57', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'ceed4c40-526f-4df1-b9cb-df90eb61b1ce', '55e35ecfc1ede3408937382965d3c62f595d73ebdb5a87ff2821478bd4e30fdf', '2025-11-19 13:55:10', 1, '2025-11-12 13:56:57', '2025-11-12 13:55:10', NULL);
INSERT INTO `refresh_tokens` VALUES ('059fe157-a85e-4b65-9c3a-29077b605a1b', '790de8f0-0574-4d28-bd62-d04d4a85b793', '422751cb-9b9b-471c-9822-be9bde200bb4', '6497703e96ba16acaa8a3b463aa67eddce79ac5216ff2932e39741ab7fefc1b0', '2025-11-18 18:01:28', 0, NULL, '2025-11-11 18:01:28', NULL);
INSERT INTO `refresh_tokens` VALUES ('082a372f-cb01-42dc-8096-35c3eb4e15f1', '790de8f0-0574-4d28-bd62-d04d4a85b793', '71a3284a-b515-4857-8119-8cfecfb11d9e', '990adbf4988438d316af148ce49bf59e2ee1f75afb7de0c3a684cfe9cce2f48e', '2025-11-18 16:43:06', 1, '2025-11-11 17:10:29', '2025-11-11 16:43:06', NULL);
INSERT INTO `refresh_tokens` VALUES ('0eb47daf-7d9b-48c3-9e03-a60a0f80b92b', '790de8f0-0574-4d28-bd62-d04d4a85b793', '36969c0b-a321-43bf-8c46-7d7ebcdf108e', '9de69031d92c43e76883210f8367920b9918adb28ee7cfa88dbfa047abda700a', '2025-11-18 18:04:48', 1, '2025-11-11 18:05:28', '2025-11-11 18:04:48', NULL);
INSERT INTO `refresh_tokens` VALUES ('14baac87-3494-42dd-ae30-af32ddd0b938', '790de8f0-0574-4d28-bd62-d04d4a85b793', '71a3284a-b515-4857-8119-8cfecfb11d9e', '5466a69821563c088ce6ebcc1763283f11b79369efc9a6ac1a22011bf15ce4f7', '2025-11-18 17:10:29', 0, NULL, '2025-11-11 17:10:29', NULL);
INSERT INTO `refresh_tokens` VALUES ('155aac8d-20d3-41b4-8c2f-b9ab7bc722be', '790de8f0-0574-4d28-bd62-d04d4a85b793', '36969c0b-a321-43bf-8c46-7d7ebcdf108e', '3276f47ac19fc424f61b091d1c8ec029fa8f2e2310a95ad016356c986f22fa79', '2025-11-19 13:48:03', 1, '2025-11-12 13:51:00', '2025-11-12 13:48:03', NULL);
INSERT INTO `refresh_tokens` VALUES ('17593e5e-73e6-427f-bf9b-d141421aee80', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'ceed4c40-526f-4df1-b9cb-df90eb61b1ce', '7947ac6e118ea139ddf9fc24ba6e9237a5e81aa9a2977dc51ee47dd2ee67a7c3', '2025-11-19 13:54:52', 1, '2025-11-12 13:54:52', '2025-11-12 13:54:52', NULL);
INSERT INTO `refresh_tokens` VALUES ('1ec9aeb2-ef6c-4690-81cc-211515c85b20', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'ceed4c40-526f-4df1-b9cb-df90eb61b1ce', '117517d6dc502b85579e8fa2246ec4eab3c6fde6240f9b3378e5abe34bb3bbab', '2025-11-19 13:52:34', 1, '2025-11-12 13:52:40', '2025-11-12 13:52:34', NULL);
INSERT INTO `refresh_tokens` VALUES ('2219f561-ebfc-47fe-908f-703d2a5aaf21', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'ceed4c40-526f-4df1-b9cb-df90eb61b1ce', '45257413e18fb947b3a21b9fbf63a28056597fc922445f691c9dc77e60cdc9c1', '2025-11-19 13:54:52', 1, '2025-11-12 13:55:06', '2025-11-12 13:54:52', NULL);
INSERT INTO `refresh_tokens` VALUES ('279118ae-5841-4ab2-ad2f-3d276083bf50', '790de8f0-0574-4d28-bd62-d04d4a85b793', '36969c0b-a321-43bf-8c46-7d7ebcdf108e', '423678ae846e1bbb7702a1126f521d4926cf0775ee278fde7cb6e174c5c3d90f', '2025-11-18 18:03:59', 1, '2025-11-11 18:03:59', '2025-11-11 18:03:59', NULL);
INSERT INTO `refresh_tokens` VALUES ('2c8ec29e-8a9a-4c9e-9c20-fc4aa3172a49', '790de8f0-0574-4d28-bd62-d04d4a85b793', '36969c0b-a321-43bf-8c46-7d7ebcdf108e', '616927047c7c06321b91fce8118689951a54e12f58da78d691bbc428031d9991', '2025-11-18 18:03:41', 1, '2025-11-11 18:03:41', '2025-11-11 18:03:41', NULL);
INSERT INTO `refresh_tokens` VALUES ('2d506bc4-3350-4a51-8379-9eeafe433c18', '790de8f0-0574-4d28-bd62-d04d4a85b793', '4b25a3c8-cf9d-4fd7-9153-74df4100a9b7', '773c59f69162bf1ab5d65256e6234c56e925bdaeb509a086558fd6bce2cb142a', '2025-11-19 13:58:08', 0, NULL, '2025-11-12 13:58:08', NULL);
INSERT INTO `refresh_tokens` VALUES ('30448482-1dc6-4cb0-b568-0856f2c13ea1', '790de8f0-0574-4d28-bd62-d04d4a85b793', '0452affe-19a1-46cc-88e9-cef80e7f5045', '732c09781aa1561cf56f1a0ad9a79d2d000b5489eac616480d9f1306db5d5a51', '2025-11-19 13:57:04', 1, '2025-11-12 13:57:04', '2025-11-12 13:57:04', NULL);
INSERT INTO `refresh_tokens` VALUES ('32f9ea9c-189c-43ef-9e96-2a6024d67aa9', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'ceed4c40-526f-4df1-b9cb-df90eb61b1ce', 'a5f7c66fd51c540e799c6af4be506d4090df2a3398c8b817b6ae5d71c036724f', '2025-11-19 13:53:28', 1, '2025-11-12 13:54:52', '2025-11-12 13:53:28', NULL);
INSERT INTO `refresh_tokens` VALUES ('361e8e40-fdc1-4ca0-b832-d9b3e440777c', '790de8f0-0574-4d28-bd62-d04d4a85b793', '0452affe-19a1-46cc-88e9-cef80e7f5045', '123f35cb2ae4b83586f316588f2b2ca553506715772b04ae7aa0b362596cca58', '2025-11-19 13:57:05', 0, NULL, '2025-11-12 13:57:05', NULL);
INSERT INTO `refresh_tokens` VALUES ('3df89126-c596-470a-a5d8-a3298baffc1d', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'ceed4c40-526f-4df1-b9cb-df90eb61b1ce', 'c179a9f15cae2d0451afa4370a590a24e4393deec407de0b949a7583d0b3a6d8', '2025-11-19 13:56:57', 0, NULL, '2025-11-12 13:56:57', NULL);
INSERT INTO `refresh_tokens` VALUES ('40d2b136-f326-488f-abd5-61104cbb130a', '790de8f0-0574-4d28-bd62-d04d4a85b793', '183152cc-dc0d-4002-a04d-9e4419ea18c1', '86dba67c481a5cc5a1f3cecfdab6914e8c08babc935cb054a92300ed95cfe050', '2025-11-18 16:41:53', 0, NULL, '2025-11-11 16:41:53', NULL);
INSERT INTO `refresh_tokens` VALUES ('426140cc-fc8a-4faf-87af-edd14d4363f4', '790de8f0-0574-4d28-bd62-d04d4a85b793', '36969c0b-a321-43bf-8c46-7d7ebcdf108e', '9727c58b9e8c6c7141bf45e359de23870641584e2624626e83fcc7ba01f29c02', '2025-11-18 18:05:43', 1, '2025-11-11 18:39:47', '2025-11-11 18:05:43', NULL);
INSERT INTO `refresh_tokens` VALUES ('4683dfb4-80b9-479b-bf2f-1b09656ffcf4', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'f0c4c47b-9999-4d8f-a5a4-e8753139b7e3', '2d596928f479cf631008268b15628c57dfdde61cdbdc32e9ba1edce38282f039', '2025-11-18 17:59:31', 0, NULL, '2025-11-11 17:59:31', NULL);
INSERT INTO `refresh_tokens` VALUES ('4917a00c-5e63-4f32-a23b-7f9d68f85ef2', '790de8f0-0574-4d28-bd62-d04d4a85b793', '4b25a3c8-cf9d-4fd7-9153-74df4100a9b7', '80d0c43a14accdd42e0dfb3ed5594fa079ff6082f74fc0c431f787a774362dce', '2025-11-19 13:58:07', 1, '2025-11-12 13:58:07', '2025-11-12 13:58:07', NULL);
INSERT INTO `refresh_tokens` VALUES ('4a83bdf7-43f4-4429-b407-367eed74acd0', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'ceed4c40-526f-4df1-b9cb-df90eb61b1ce', '90fa1deebe42b83a46375092f2ff547431b01a437e201bfc203ec5830895a8da', '2025-11-19 13:52:34', 1, '2025-11-12 13:52:34', '2025-11-12 13:52:34', NULL);
INSERT INTO `refresh_tokens` VALUES ('4cac0ff4-4eb1-4e93-bf48-2a83869769cc', '790de8f0-0574-4d28-bd62-d04d4a85b793', '36969c0b-a321-43bf-8c46-7d7ebcdf108e', 'be9208c8bdc4df090b6d7584b7849369b8ed8d8660a458773397bcb3f4e50d3e', '2025-11-19 13:52:21', 1, '2025-11-12 13:52:21', '2025-11-12 13:52:21', NULL);
INSERT INTO `refresh_tokens` VALUES ('6786c5f6-b75f-4c68-bbfd-04f50f406082', '790de8f0-0574-4d28-bd62-d04d4a85b793', '55c37648-809f-4e2b-9413-105e0d711a09', 'b9a37c6f21b78cd1addeeda735f71e237710a9b7753450eebd209846db6c234a', '2025-11-19 14:06:19', 0, NULL, '2025-11-12 14:06:19', NULL);
INSERT INTO `refresh_tokens` VALUES ('6c78f5e4-fb52-4223-be28-63f1f01570b6', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'ceed4c40-526f-4df1-b9cb-df90eb61b1ce', 'e731757bfbea304a4b8a5b0339dab8358aff50e15aefc871f5c4e20404083b5b', '2025-11-19 13:52:40', 1, '2025-11-12 13:52:58', '2025-11-12 13:52:40', NULL);
INSERT INTO `refresh_tokens` VALUES ('6ce80188-7fd0-46a3-ba1b-239f4ff43454', '790de8f0-0574-4d28-bd62-d04d4a85b793', '36969c0b-a321-43bf-8c46-7d7ebcdf108e', '7b5cb3ed9fd39ae52b79db528bad7ed2db43efa0c14134b2c81c3c706d17a99d', '2025-11-19 13:52:21', 0, NULL, '2025-11-12 13:52:21', NULL);
INSERT INTO `refresh_tokens` VALUES ('71f89942-5481-46a7-9e34-b10c8d8450b9', '790de8f0-0574-4d28-bd62-d04d4a85b793', '36969c0b-a321-43bf-8c46-7d7ebcdf108e', '3047c215d5da187f41f058bc858973e2cb24e9389a801051cd106bd2b49be19d', '2025-11-18 18:05:40', 1, '2025-11-11 18:05:41', '2025-11-11 18:05:40', NULL);
INSERT INTO `refresh_tokens` VALUES ('767dad56-7748-45b9-b937-00401f3927bd', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'f0c4c47b-9999-4d8f-a5a4-e8753139b7e3', '23ac0d4f6d9339b42db87b612802aa663070ed22bfb091f1e31d0ec38f0e642a', '2025-11-18 17:59:28', 1, '2025-11-11 17:59:31', '2025-11-11 17:59:28', NULL);
INSERT INTO `refresh_tokens` VALUES ('7aeeccbe-22e8-41d1-80ca-47b4c6e3835f', '790de8f0-0574-4d28-bd62-d04d4a85b793', '4b25a3c8-cf9d-4fd7-9153-74df4100a9b7', '0c5e22e7fbf4514e7734d72a00be2129eeb010b77ffbe894e18c65d392dab30c', '2025-11-19 13:58:07', 1, '2025-11-12 13:58:08', '2025-11-12 13:58:07', NULL);
INSERT INTO `refresh_tokens` VALUES ('7c12c0b7-aee2-45c0-864b-0ce0688faf3d', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'e33c5ca6-d9a3-4abc-b1d6-bfe0bc84b0b5', '939288c5aca0ac6e92294a4ad55ef957cb7c715050bba931e54551d9c402e359', '2025-11-18 18:02:09', 0, NULL, '2025-11-11 18:02:09', NULL);
INSERT INTO `refresh_tokens` VALUES ('80c0f562-3c80-41f1-9eba-41f7df84120c', '790de8f0-0574-4d28-bd62-d04d4a85b793', '36969c0b-a321-43bf-8c46-7d7ebcdf108e', '26b923e912323db2992cbb535b920ef05b4788db0a069dee15e1dd55176374ba', '2025-11-18 18:03:59', 1, '2025-11-11 18:04:06', '2025-11-11 18:03:59', NULL);
INSERT INTO `refresh_tokens` VALUES ('85740c02-a7b5-4624-906d-0d8a0333948b', '790de8f0-0574-4d28-bd62-d04d4a85b793', '2c9c740c-1e8e-4a3d-a052-a29e0beedf19', 'e9c618823cf93a605dc02838d2c9a7ee1e1099b398fffe6d253107bb13de4446', '2025-11-19 17:22:50', 1, '2025-11-13 14:01:49', '2025-11-12 17:22:50', NULL);
INSERT INTO `refresh_tokens` VALUES ('89cd9109-5637-47f1-934f-e7bfc1be8848', '790de8f0-0574-4d28-bd62-d04d4a85b793', '36969c0b-a321-43bf-8c46-7d7ebcdf108e', 'df1c4306546ef1d2967c290de2804f1b39c1f11a655ef10bf5c126e6713201ca', '2025-11-18 18:05:41', 1, '2025-11-11 18:05:42', '2025-11-11 18:05:41', NULL);
INSERT INTO `refresh_tokens` VALUES ('90ef85bd-190f-4eb2-80b2-21209b50fe85', '790de8f0-0574-4d28-bd62-d04d4a85b793', '36969c0b-a321-43bf-8c46-7d7ebcdf108e', 'fb77e9b7fce0b4dec6fc638fe52b0bc745381cf9453e20464e050a5d0e8561a1', '2025-11-18 18:05:28', 1, '2025-11-11 18:05:39', '2025-11-11 18:05:28', NULL);
INSERT INTO `refresh_tokens` VALUES ('97853d61-95de-46cf-a165-11b20fe538d3', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'ceed4c40-526f-4df1-b9cb-df90eb61b1ce', 'e24210977ae89f5eba6b31e1e59dd8d9e98972214a00276f1947c98acfd4f408', '2025-11-19 13:55:06', 1, '2025-11-12 13:55:09', '2025-11-12 13:55:06', NULL);
INSERT INTO `refresh_tokens` VALUES ('9ccdb48b-5bed-4468-87c9-0a6c3f271902', '790de8f0-0574-4d28-bd62-d04d4a85b793', '9edbf642-82a9-412f-b355-00ee9bf9ca8c', '9a83b3bd9e7ff7986b48cd968d42d92016b718fb2904dbcf51d69a8afcd11a3f', '2025-11-19 15:19:59', 0, NULL, '2025-11-12 15:19:59', NULL);
INSERT INTO `refresh_tokens` VALUES ('a17b361f-b7e8-4abc-8e96-3480dced582b', '790de8f0-0574-4d28-bd62-d04d4a85b793', '586edef2-a011-41af-b474-c666bda8317c', '764ba6795e28436773aef5b9af6f22eb27be99e8a0e2f8e1ea8db4d912d1670f', '2025-11-19 16:29:45', 0, NULL, '2025-11-12 16:29:45', NULL);
INSERT INTO `refresh_tokens` VALUES ('a1a898e2-b96b-4167-a973-fd3cdc35bc5f', '790de8f0-0574-4d28-bd62-d04d4a85b793', '36969c0b-a321-43bf-8c46-7d7ebcdf108e', '2e9a23baa121f7467fc6be220dd8baae1c5d7ff7e8246cc127199e7ca3cf6a55', '2025-11-18 18:39:47', 1, '2025-11-12 13:42:08', '2025-11-11 18:39:47', NULL);
INSERT INTO `refresh_tokens` VALUES ('a344165c-4168-4d5b-9ea0-fd87f98136a9', '790de8f0-0574-4d28-bd62-d04d4a85b793', '37410660-e6b7-4476-9c2a-2a9b090f816b', 'aca269a3f8cec0e67eef4e69e3b612bedaad9060f377b65c5264e5f18c5c2e4e', '2025-11-18 18:00:51', 0, NULL, '2025-11-11 18:00:51', NULL);
INSERT INTO `refresh_tokens` VALUES ('a8385cca-5109-46b1-87ac-490f74a8ca20', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'ceed4c40-526f-4df1-b9cb-df90eb61b1ce', '7da49ca2a3b7165f5f9718718233eb0f92cf6b07b1a7a3a91882803ea9a8f80c', '2025-11-19 13:52:58', 1, '2025-11-12 13:52:58', '2025-11-12 13:52:58', NULL);
INSERT INTO `refresh_tokens` VALUES ('a8fb3aee-c9bb-469d-a23f-75e945e4262f', '790de8f0-0574-4d28-bd62-d04d4a85b793', '36969c0b-a321-43bf-8c46-7d7ebcdf108e', 'c5ca35fe39e1d876f4a9cd372fbdbdeaf5736cc6ab174f049c6bf9db56ac3128', '2025-11-18 18:03:51', 1, '2025-11-11 18:03:59', '2025-11-11 18:03:51', NULL);
INSERT INTO `refresh_tokens` VALUES ('aad7fe0e-28c1-4d00-b83a-0d294aceead8', '790de8f0-0574-4d28-bd62-d04d4a85b793', '36969c0b-a321-43bf-8c46-7d7ebcdf108e', 'bb9edff272a7de16d449232ed0a52ab98b36971679d601608ffbb93bf9f853cd', '2025-11-18 18:04:06', 1, '2025-11-11 18:04:47', '2025-11-11 18:04:06', NULL);
INSERT INTO `refresh_tokens` VALUES ('adf00832-8b3e-4045-b866-75edd91531ec', '790de8f0-0574-4d28-bd62-d04d4a85b793', '36969c0b-a321-43bf-8c46-7d7ebcdf108e', '0086bece3d76ae1b20beee6df6cff763b5c3ac2441a6d2830c28b044eb8d34f6', '2025-11-18 18:03:41', 1, '2025-11-11 18:03:49', '2025-11-11 18:03:41', NULL);
INSERT INTO `refresh_tokens` VALUES ('ae9b8a2c-67ec-4d00-9a66-42beb62e8e6d', '790de8f0-0574-4d28-bd62-d04d4a85b793', '770751f8-6bee-4abe-bc81-9fd21c280490', '0fa1cfd4ce881f70d31e185a1339c28154b2e45fb73e42ad2b751f33d542d680', '2025-11-18 17:59:36', 0, NULL, '2025-11-11 17:59:36', NULL);
INSERT INTO `refresh_tokens` VALUES ('af6cf8ca-2aa2-464f-b812-444ba8f7431e', '790de8f0-0574-4d28-bd62-d04d4a85b793', '36969c0b-a321-43bf-8c46-7d7ebcdf108e', '2a7ba2eb1a325bce00bd7cc989c901ce31c6c5bb9c7b15eebec564127b481c9f', '2025-11-19 13:42:08', 1, '2025-11-12 13:48:03', '2025-11-12 13:42:08', NULL);
INSERT INTO `refresh_tokens` VALUES ('bb8eace1-5db7-42f4-9ad4-b8e2f24efe3a', '790de8f0-0574-4d28-bd62-d04d4a85b793', '0452affe-19a1-46cc-88e9-cef80e7f5045', 'c6be7ac1c11b9d0c6a31c491d9c137973fac61c655cec1fbd6b224aa28006f86', '2025-11-19 13:57:04', 1, '2025-11-12 13:57:05', '2025-11-12 13:57:04', NULL);
INSERT INTO `refresh_tokens` VALUES ('c0b41be6-cb54-4083-918c-6041ed774f2b', '790de8f0-0574-4d28-bd62-d04d4a85b793', '86b2635c-279c-4231-9918-3e079f5f4d0c', '4c7ab25e1369cdf4dcca3cda94f9ba2ab308da9fb94072b303d780f6018f955f', '2025-11-18 17:59:47', 0, NULL, '2025-11-11 17:59:47', NULL);
INSERT INTO `refresh_tokens` VALUES ('ca81d931-326e-4bcc-8c2c-4f4400115e9f', '790de8f0-0574-4d28-bd62-d04d4a85b793', '36969c0b-a321-43bf-8c46-7d7ebcdf108e', 'e74fbbc327002e2a6d42545aeaac1cb605eb22b00ace45b7376f2fbdb599ff24', '2025-11-18 18:04:47', 1, '2025-11-11 18:04:48', '2025-11-11 18:04:47', NULL);
INSERT INTO `refresh_tokens` VALUES ('d3c39e19-5d3c-4e3b-8e49-67282ab1a8dc', '790de8f0-0574-4d28-bd62-d04d4a85b793', '36969c0b-a321-43bf-8c46-7d7ebcdf108e', 'ac9b2c26f3a292c2d1f73f9052f4a25c8785a22c616b5cd97b7f1eddf3a5c8ba', '2025-11-18 18:05:40', 1, '2025-11-11 18:05:40', '2025-11-11 18:05:40', NULL);
INSERT INTO `refresh_tokens` VALUES ('d8068d99-7913-4a55-b557-946c8bf4fd19', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'ceed4c40-526f-4df1-b9cb-df90eb61b1ce', 'f21def046083ea28da1f4885a4d3ace75f93543c1dd89032c6dd5d3226fdb049', '2025-11-19 13:52:59', 1, '2025-11-12 13:53:28', '2025-11-12 13:52:59', NULL);
INSERT INTO `refresh_tokens` VALUES ('d87a9a01-b044-48e6-a0d2-72723aaaf225', '790de8f0-0574-4d28-bd62-d04d4a85b793', '36969c0b-a321-43bf-8c46-7d7ebcdf108e', 'f2b88532623832d07c322e4cb54f77280df8404f084b4569f295c9ecef5f705e', '2025-11-18 18:05:39', 1, '2025-11-11 18:05:40', '2025-11-11 18:05:39', NULL);
INSERT INTO `refresh_tokens` VALUES ('dff522dc-cb7c-4b5a-a813-d305b6064fcc', '790de8f0-0574-4d28-bd62-d04d4a85b793', '36969c0b-a321-43bf-8c46-7d7ebcdf108e', '3cf32be9a7f145fc6956614d665901d86256ae266a1ef0a8e5baa78c83f6ee6e', '2025-11-18 18:03:49', 1, '2025-11-11 18:03:51', '2025-11-11 18:03:49', NULL);
INSERT INTO `refresh_tokens` VALUES ('e069c9c7-49bc-4a80-9c65-9f1afa5672ae', '790de8f0-0574-4d28-bd62-d04d4a85b793', '36969c0b-a321-43bf-8c46-7d7ebcdf108e', 'eb234a757d1f31ec8ef8a1b083f040b35f4fe6e0faeb1ebc0f0038b8bee19e4c', '2025-11-19 13:51:00', 1, '2025-11-12 13:52:21', '2025-11-12 13:51:00', NULL);
INSERT INTO `refresh_tokens` VALUES ('e12556b8-59bd-4bb1-aea9-adb79dfe7435', '790de8f0-0574-4d28-bd62-d04d4a85b793', '36969c0b-a321-43bf-8c46-7d7ebcdf108e', '6a65515880af99b76756ddbe47f51cd01367cf0d8d5b203b05162de6f6047a32', '2025-11-18 18:05:42', 1, '2025-11-11 18:05:43', '2025-11-11 18:05:42', NULL);
INSERT INTO `refresh_tokens` VALUES ('e1699d41-28e6-4899-b16a-e530956175ee', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'ceed4c40-526f-4df1-b9cb-df90eb61b1ce', 'a2fa4984dd4a6c272745cc6efdc5e1b31ad40c5736b02ff1463c344dfed66607', '2025-11-19 13:55:09', 1, '2025-11-12 13:55:09', '2025-11-12 13:55:09', NULL);
INSERT INTO `refresh_tokens` VALUES ('e753f300-9666-4c7e-9c62-840d14fbc98d', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'b4a91411-4d25-4324-848b-9ec990337cda', 'f7e6af603f296771a8300f44cbb9278f22d64b44e103b20bce0bba573171c278', '2025-11-19 14:39:37', 0, NULL, '2025-11-12 14:39:37', NULL);
INSERT INTO `refresh_tokens` VALUES ('efcb9da7-90c5-4a06-a0e9-ea4e8258f0a3', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'ceed4c40-526f-4df1-b9cb-df90eb61b1ce', '4b1f06c91f1517aa1b0bae300be9fffcc761b68b6132a5bca7f2999765267992', '2025-11-19 13:53:28', 1, '2025-11-12 13:53:28', '2025-11-12 13:53:28', NULL);
INSERT INTO `refresh_tokens` VALUES ('fc0f3799-48b8-4e3c-8e67-26cc272593fa', '790de8f0-0574-4d28-bd62-d04d4a85b793', '2c9c740c-1e8e-4a3d-a052-a29e0beedf19', '59e3e6d398947edfdbd8d9ef7c943586ba24a47bcb4b662961d7fcb1555c66db', '2025-11-20 14:01:49', 0, NULL, '2025-11-13 14:01:49', NULL);

-- ----------------------------
-- Table structure for sessions
-- ----------------------------
DROP TABLE IF EXISTS `sessions`;
CREATE TABLE `sessions`  (
  `id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `user_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NOT NULL,
  `ip_address` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `user_agent` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `device_name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `latitude` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `longitude` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL DEFAULT NULL,
  `payload` longtext CHARACTER SET utf8mb4 COLLATE utf8mb4_general_ci NULL,
  `last_activity` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `revoked_at` timestamp NULL DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `updated_at` timestamp NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_general_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of sessions
-- ----------------------------
INSERT INTO `sessions` VALUES ('0452affe-19a1-46cc-88e9-cef80e7f5045', '790de8f0-0574-4d28-bd62-d04d4a85b793', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'Windows PC', NULL, NULL, '{\"loginMethod\":\"password\",\"usernameOrEmail\":\"superadmin\"}', '2025-11-12 13:57:05', '2025-11-12 23:25:13', '2025-11-12 13:57:04', '2025-11-12 23:25:17');
INSERT INTO `sessions` VALUES ('183152cc-dc0d-4002-a04d-9e4419ea18c1', '790de8f0-0574-4d28-bd62-d04d4a85b793', '127.0.0.1', 'Apidog/1.0.0 (https://apidog.com)', 'Unknown Device', NULL, NULL, '{\"loginMethod\":\"password\",\"usernameOrEmail\":\"superadmin\"}', '2025-11-11 16:41:53', '2025-11-12 23:25:13', '2025-11-11 16:41:53', '2025-11-12 23:25:21');
INSERT INTO `sessions` VALUES ('2c9c740c-1e8e-4a3d-a052-a29e0beedf19', '790de8f0-0574-4d28-bd62-d04d4a85b793', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'Windows PC', NULL, NULL, '{\"loginMethod\":\"password\",\"usernameOrEmail\":\"superadmin\"}', '2025-11-13 14:01:49', NULL, '2025-11-12 17:22:50', '2025-11-13 14:01:49');
INSERT INTO `sessions` VALUES ('36969c0b-a321-43bf-8c46-7d7ebcdf108e', '790de8f0-0574-4d28-bd62-d04d4a85b793', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'Windows PC', NULL, NULL, '{\"loginMethod\":\"password\",\"usernameOrEmail\":\"superadmin\"}', '2025-11-12 13:52:21', '2025-11-12 23:25:13', '2025-11-11 18:03:41', '2025-11-12 23:25:21');
INSERT INTO `sessions` VALUES ('37410660-e6b7-4476-9c2a-2a9b090f816b', '790de8f0-0574-4d28-bd62-d04d4a85b793', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'Windows PC', NULL, NULL, '{\"loginMethod\":\"password\",\"usernameOrEmail\":\"superadmin\"}', '2025-11-11 18:00:51', '2025-11-12 23:25:13', '2025-11-11 18:00:51', '2025-11-12 23:25:21');
INSERT INTO `sessions` VALUES ('422751cb-9b9b-471c-9822-be9bde200bb4', '790de8f0-0574-4d28-bd62-d04d4a85b793', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'Windows PC', NULL, NULL, '{\"loginMethod\":\"password\",\"usernameOrEmail\":\"superadmin\"}', '2025-11-11 18:01:28', '2025-11-12 23:25:13', '2025-11-11 18:01:28', '2025-11-12 23:25:21');
INSERT INTO `sessions` VALUES ('4b25a3c8-cf9d-4fd7-9153-74df4100a9b7', '790de8f0-0574-4d28-bd62-d04d4a85b793', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'Windows PC', NULL, NULL, '{\"loginMethod\":\"password\",\"usernameOrEmail\":\"superadmin\"}', '2025-11-12 13:58:08', '2025-11-12 23:25:13', '2025-11-12 13:58:07', '2025-11-12 23:25:21');
INSERT INTO `sessions` VALUES ('55c37648-809f-4e2b-9413-105e0d711a09', '790de8f0-0574-4d28-bd62-d04d4a85b793', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'Windows PC', NULL, NULL, '{\"loginMethod\":\"password\",\"usernameOrEmail\":\"superadmin\"}', '2025-11-12 14:06:19', '2025-11-12 23:25:13', '2025-11-12 14:06:19', '2025-11-12 23:25:21');
INSERT INTO `sessions` VALUES ('586edef2-a011-41af-b474-c666bda8317c', '790de8f0-0574-4d28-bd62-d04d4a85b793', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'Windows PC', NULL, NULL, '{\"loginMethod\":\"password\",\"usernameOrEmail\":\"superadmin\"}', '2025-11-12 16:29:45', '2025-11-12 23:25:13', '2025-11-12 16:29:45', '2025-11-12 23:32:53');
INSERT INTO `sessions` VALUES ('71a3284a-b515-4857-8119-8cfecfb11d9e', '790de8f0-0574-4d28-bd62-d04d4a85b793', '127.0.0.1', 'Apidog/1.0.0 (https://apidog.com)', 'Chrome on Windows', '-6.200000', '106.816666', '{\"loginMethod\":\"password\",\"usernameOrEmail\":\"superadmin\"}', '2025-11-11 17:10:29', '2025-11-12 23:25:13', '2025-11-11 16:43:06', '2025-11-12 23:25:21');
INSERT INTO `sessions` VALUES ('770751f8-6bee-4abe-bc81-9fd21c280490', '790de8f0-0574-4d28-bd62-d04d4a85b793', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'Windows PC', NULL, NULL, '{\"loginMethod\":\"password\",\"usernameOrEmail\":\"superadmin\"}', '2025-11-11 17:59:36', '2025-11-12 23:25:13', '2025-11-11 17:59:36', '2025-11-12 23:25:21');
INSERT INTO `sessions` VALUES ('86b2635c-279c-4231-9918-3e079f5f4d0c', '790de8f0-0574-4d28-bd62-d04d4a85b793', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'Windows PC', NULL, NULL, '{\"loginMethod\":\"password\",\"usernameOrEmail\":\"superadmin\"}', '2025-11-11 17:59:47', '2025-11-12 23:25:13', '2025-11-11 17:59:47', '2025-11-12 23:25:21');
INSERT INTO `sessions` VALUES ('9edbf642-82a9-412f-b355-00ee9bf9ca8c', '790de8f0-0574-4d28-bd62-d04d4a85b793', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'Windows PC', NULL, NULL, '{\"loginMethod\":\"password\",\"usernameOrEmail\":\"superadmin\"}', '2025-11-12 15:19:59', '2025-11-12 23:25:13', '2025-11-12 15:19:59', '2025-11-12 23:25:21');
INSERT INTO `sessions` VALUES ('b4a91411-4d25-4324-848b-9ec990337cda', '790de8f0-0574-4d28-bd62-d04d4a85b793', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'Windows PC', NULL, NULL, '{\"loginMethod\":\"password\",\"usernameOrEmail\":\"superadmin\"}', '2025-11-12 14:39:37', '2025-11-12 23:25:13', '2025-11-12 14:39:37', '2025-11-12 23:25:21');
INSERT INTO `sessions` VALUES ('ceed4c40-526f-4df1-b9cb-df90eb61b1ce', '790de8f0-0574-4d28-bd62-d04d4a85b793', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'Windows PC', NULL, NULL, '{\"loginMethod\":\"password\",\"usernameOrEmail\":\"superadmin\"}', '2025-11-12 13:56:57', '2025-11-12 23:25:13', '2025-11-12 13:52:34', '2025-11-12 23:25:21');
INSERT INTO `sessions` VALUES ('e33c5ca6-d9a3-4abc-b1d6-bfe0bc84b0b5', '790de8f0-0574-4d28-bd62-d04d4a85b793', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'Windows PC', NULL, NULL, '{\"loginMethod\":\"password\",\"usernameOrEmail\":\"superadmin\"}', '2025-11-11 18:02:09', '2025-11-12 23:25:13', '2025-11-11 18:02:09', '2025-11-12 23:25:21');
INSERT INTO `sessions` VALUES ('f0c4c47b-9999-4d8f-a5a4-e8753139b7e3', '790de8f0-0574-4d28-bd62-d04d4a85b793', '127.0.0.1', 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/142.0.0.0 Safari/537.36', 'Windows PC', NULL, NULL, '{\"loginMethod\":\"password\",\"usernameOrEmail\":\"superadmin\"}', '2025-11-11 17:59:31', '2025-11-12 23:25:13', '2025-11-11 17:59:28', '2025-11-12 23:25:21');

-- ----------------------------
-- Table structure for tenant_configs
-- ----------------------------
DROP TABLE IF EXISTS `tenant_configs`;
CREATE TABLE `tenant_configs`  (
  `id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `tenant_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `config_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `config_value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `config_type` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `tenant_configs_tenant_id_config_key_unique`(`tenant_id` ASC, `config_key` ASC) USING BTREE,
  CONSTRAINT `tenant_configs_tenant_id_foreign` FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`) ON DELETE CASCADE ON UPDATE RESTRICT
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of tenant_configs
-- ----------------------------
INSERT INTO `tenant_configs` VALUES ('04309b60-9adc-4cf9-aaed-84036af88032', '0fc42307-c7ae-4de3-a9c8-24f3937058b7', 'default_vat_percentage', '10', 'number', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `tenant_configs` VALUES ('0cd338b1-8eec-412c-9207-08b4ef0ebbe1', '0fc42307-c7ae-4de3-a9c8-24f3937058b7', 'generate_invoice_receipt_by', 'sales_order_delivery', 'select', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `tenant_configs` VALUES ('0df7bd2a-cf27-431b-bac9-cc7a1873ded3', '0fc42307-c7ae-4de3-a9c8-24f3937058b7', 'main_currency', 'IDR', 'string', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `tenant_configs` VALUES ('1171ee14-b58d-4389-8b6b-bd789ec6cad2', '0fc42307-c7ae-4de3-a9c8-24f3937058b7', 'item_auto_generate_code', 'true', 'boolean', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `tenant_configs` VALUES ('247f07d2-e64e-48ae-9107-fc574c2f4ede', '0fc42307-c7ae-4de3-a9c8-24f3937058b7', 'available_vat', 'true', 'boolean', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `tenant_configs` VALUES ('2c2638b5-1057-4d60-ab6a-04709c5099a0', '0fc42307-c7ae-4de3-a9c8-24f3937058b7', 'currency_format', 'Rp #,##0', 'select', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `tenant_configs` VALUES ('40fc6b5f-3bf9-491c-ae97-ddc2a8d75b35', '0fc42307-c7ae-4de3-a9c8-24f3937058b7', 'date_format', 'Y-m-d', 'select', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `tenant_configs` VALUES ('51d844e8-76a9-47ff-b9a8-9d3b033e70aa', '0fc42307-c7ae-4de3-a9c8-24f3937058b7', 'generate_invoice_payment_by', 'purchase_receipt', 'select', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `tenant_configs` VALUES ('63da3720-fb7e-436c-b0fc-483d660e1bf2', '0fc42307-c7ae-4de3-a9c8-24f3937058b7', 'auto_generate_invoice_payment', 'true', 'boolean', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `tenant_configs` VALUES ('6c1fd517-722c-486b-a94a-10ebd4553773', '0fc42307-c7ae-4de3-a9c8-24f3937058b7', 'default_language', 'id', 'select', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `tenant_configs` VALUES ('6d187784-6305-4376-b72b-71782b6d5342', '0fc42307-c7ae-4de3-a9c8-24f3937058b7', 'timezone', 'Asia/Jakarta', 'select', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `tenant_configs` VALUES ('7972611e-fd5f-4c4a-a8a8-4e8e9b6d2943', '0fc42307-c7ae-4de3-a9c8-24f3937058b7', 'margin_percentage', 'true', 'boolean', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `tenant_configs` VALUES ('93eaca57-1381-4cd1-88da-af20d2594878', '0fc42307-c7ae-4de3-a9c8-24f3937058b7', 'accounting_fiscal_year_start', '2025-01', 'string', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `tenant_configs` VALUES ('96ec139c-4b06-4337-87d3-d0d1637fd62d', '0fc42307-c7ae-4de3-a9c8-24f3937058b7', 'auto_generate_invoice_receipt', 'true', 'boolean', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `tenant_configs` VALUES ('c1d86219-ad5b-421c-b0f9-91be9bd60f94', '0fc42307-c7ae-4de3-a9c8-24f3937058b7', 'minimum_stock_alert', 'true', 'boolean', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `tenant_configs` VALUES ('e68fa7cf-9704-475b-9138-9ed12d5e68ca', '0fc42307-c7ae-4de3-a9c8-24f3937058b7', 'enable_minimum_margin', 'true', 'boolean', '2025-11-05 23:38:09', '2025-11-05 23:38:09');

-- ----------------------------
-- Table structure for tenant_connections
-- ----------------------------
DROP TABLE IF EXISTS `tenant_connections`;
CREATE TABLE `tenant_connections`  (
  `id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `tenant_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `connection_name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `database_prefix` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of tenant_connections
-- ----------------------------

-- ----------------------------
-- Table structure for tenant_has_service
-- ----------------------------
DROP TABLE IF EXISTS `tenant_has_service`;
CREATE TABLE `tenant_has_service`  (
  `tenant_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `service_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`tenant_id`, `service_key`) USING BTREE,
  INDEX `idx_tenant_id`(`tenant_id` ASC) USING BTREE,
  INDEX `idx_service_key`(`service_key` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of tenant_has_service
-- ----------------------------
INSERT INTO `tenant_has_service` VALUES ('0fc42307-c7ae-4de3-a9c8-24f3937058b7', 'accounting', NULL, NULL);
INSERT INTO `tenant_has_service` VALUES ('0fc42307-c7ae-4de3-a9c8-24f3937058b7', 'admin_portal', NULL, NULL);
INSERT INTO `tenant_has_service` VALUES ('0fc42307-c7ae-4de3-a9c8-24f3937058b7', 'finance', NULL, NULL);
INSERT INTO `tenant_has_service` VALUES ('0fc42307-c7ae-4de3-a9c8-24f3937058b7', 'management_stock', NULL, NULL);
INSERT INTO `tenant_has_service` VALUES ('0fc42307-c7ae-4de3-a9c8-24f3937058b7', 'procurement', NULL, NULL);
INSERT INTO `tenant_has_service` VALUES ('0fc42307-c7ae-4de3-a9c8-24f3937058b7', 'salesorder', NULL, NULL);

-- ----------------------------
-- Table structure for tenant_has_user
-- ----------------------------
DROP TABLE IF EXISTS `tenant_has_user`;
CREATE TABLE `tenant_has_user`  (
  `tenant_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `is_owner` tinyint(1) NOT NULL DEFAULT 0,
  PRIMARY KEY (`tenant_id`, `user_id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of tenant_has_user
-- ----------------------------
INSERT INTO `tenant_has_user` VALUES ('0fc42307-c7ae-4de3-a9c8-24f3937058b7', '790de8f0-0574-4d28-bd62-d04d4a85b793', 1, 0);

-- ----------------------------
-- Table structure for tenant_licenses
-- ----------------------------
DROP TABLE IF EXISTS `tenant_licenses`;
CREATE TABLE `tenant_licenses`  (
  `id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `tenant_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `license_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `value` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `tenant_licenses_license_key_unique`(`license_key` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of tenant_licenses
-- ----------------------------
INSERT INTO `tenant_licenses` VALUES ('52590076-2f6a-425a-9d04-206eed2efc82', '0fc42307-c7ae-4de3-a9c8-24f3937058b7', 'storage_limit', '1024', '2025-11-13 22:02:40', '2025-11-13 22:02:42');
INSERT INTO `tenant_licenses` VALUES ('540fbf95-73f5-4e32-b2a3-dc16c4fe6645', '0fc42307-c7ae-4de3-a9c8-24f3937058b7', 'max_users', '100', '2025-11-13 22:02:40', '2025-11-13 22:02:42');
INSERT INTO `tenant_licenses` VALUES ('7e479cca-1e49-4bc5-95d1-86e21ed7b2c9', '0fc42307-c7ae-4de3-a9c8-24f3937058b7', 'due_payment_days', '30', '2025-11-13 22:02:40', '2025-11-13 22:02:40');
INSERT INTO `tenant_licenses` VALUES ('ea0c34a5-9716-4306-85f2-ad918d04c9bb', '0fc42307-c7ae-4de3-a9c8-24f3937058b7', 'company_branches', '1', '2025-11-13 22:02:40', '2025-11-13 22:02:42');

-- ----------------------------
-- Table structure for tenants
-- ----------------------------
DROP TABLE IF EXISTS `tenants`;
CREATE TABLE `tenants`  (
  `id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `logo_path` varchar(2048) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `info_website` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `info_email` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `info_phone` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `info_tax_number` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `address` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `country` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `province` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `city` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `postal_code` varchar(20) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `status` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL DEFAULT 'trial',
  `joined_at` datetime NOT NULL DEFAULT CURRENT_TIMESTAMP,
  `expired_at` datetime NULL DEFAULT NULL,
  `revoked_at` datetime NULL DEFAULT NULL,
  `maximal_failed_login_attempts` int NOT NULL DEFAULT 5,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `tenants_code_unique`(`code` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of tenants
-- ----------------------------
INSERT INTO `tenants` VALUES ('0fc42307-c7ae-4de3-a9c8-24f3937058b7', 'Demo Tenant', 'DEMO', NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 1, 'trial', '2025-11-05 23:38:09', NULL, NULL, 5, '2025-11-05 23:38:09', '2025-11-05 23:38:09', NULL);

-- ----------------------------
-- Table structure for user_configs
-- ----------------------------
DROP TABLE IF EXISTS `user_configs`;
CREATE TABLE `user_configs`  (
  `id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `user_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `config_key` varchar(128) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `config_value` text CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of user_configs
-- ----------------------------
INSERT INTO `user_configs` VALUES ('2444c8b2-bf05-4e87-a6eb-e3a87ac3afe6', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'rtl', 'false', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `user_configs` VALUES ('8f93c8e0-bfc4-4f1a-87bd-35e68c3a4a1d', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'language', 'id', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `user_configs` VALUES ('997651fc-1f7a-4d05-be3d-9d909b9b92ae', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'content_width', 'full', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `user_configs` VALUES ('ae46b974-612a-41e1-a476-b66b30529508', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'dark_mode', 'by_system', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `user_configs` VALUES ('cb16d160-6465-4839-b1fa-45f6ddfc0b6e', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'email_notifications', 'true', '2025-11-05 23:38:09', '2025-11-05 23:38:09');
INSERT INTO `user_configs` VALUES ('d6465cd1-41d4-4c05-ac39-1269bcfa4ee4', '790de8f0-0574-4d28-bd62-d04d4a85b793', 'menu_layout', 'vertical', '2025-11-05 23:38:09', '2025-11-05 23:38:09');

-- ----------------------------
-- Table structure for users
-- ----------------------------
DROP TABLE IF EXISTS `users`;
CREATE TABLE `users`  (
  `id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `name` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `username` varchar(30) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `email` varchar(50) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `phone` varchar(15) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `email_verified_at` timestamp NULL DEFAULT NULL,
  `password` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `profile_photo_path` varchar(2048) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `failed_login_counter` int NOT NULL DEFAULT 0,
  `last_login_at` timestamp NULL DEFAULT NULL,
  `last_login_ip` varchar(45) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `last_tenant_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `last_service_key` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `is_locked` tinyint(1) NOT NULL DEFAULT 0,
  `temporary_lock_until` timestamp NULL DEFAULT NULL,
  `force_logout_at` timestamp NULL DEFAULT NULL,
  `locked_at` timestamp NULL DEFAULT NULL,
  `remember_token` varchar(100) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NULL DEFAULT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  `deleted_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`id`) USING BTREE,
  UNIQUE INDEX `users_username_unique`(`username` ASC) USING BTREE,
  UNIQUE INDEX `users_email_unique`(`email` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = DYNAMIC;

-- ----------------------------
-- Records of users
-- ----------------------------
INSERT INTO `users` VALUES ('790de8f0-0574-4d28-bd62-d04d4a85b793', 'Superadmin Demo', 'superadmin', 'syahrulsetiawan72@gmail.com', NULL, NULL, '$2y$12$VyFPeiPzsDd6PjClnBgPROgWEeOpbj3N45.Zxxwl6TRc1ZUYJrTwe', NULL, 0, '2025-11-12 17:22:50', '127.0.0.1', NULL, NULL, 0, NULL, NULL, NULL, '211d082940ef1f4bbdb3c51a44063ab5bb8f6d801e45d752abed8d67692b3e98', '2025-11-05 23:38:09', '2025-11-09 12:57:24', NULL);

-- ----------------------------
-- Procedure structure for cleanup_old_audit_logs
-- ----------------------------
DROP PROCEDURE IF EXISTS `cleanup_old_audit_logs`;
delimiter ;;
CREATE PROCEDURE `cleanup_old_audit_logs`()
BEGIN
    DECLARE deleted_count INT DEFAULT 0;
    DECLARE cutoff_date DATETIME;
    
    -- Calculate cutoff date (3 months ago)
    SET cutoff_date = DATE_SUB(NOW(), INTERVAL 3 MONTH);
    
    -- Delete old audit logs
    DELETE FROM `audit_logs` 
    WHERE `created_at` < cutoff_date;
    
    -- Get number of deleted rows
    SET deleted_count = ROW_COUNT();
    
    -- Log the cleanup action (optional)
    SELECT 
        deleted_count AS rows_deleted,
        cutoff_date AS deleted_before,
        NOW() AS cleanup_executed_at;
END
;;
delimiter ;

-- ----------------------------
-- Procedure structure for cleanup_expired_tokens_and_sessions
-- ----------------------------
DROP PROCEDURE IF EXISTS `cleanup_expired_tokens_and_sessions`;
delimiter ;;
CREATE PROCEDURE `cleanup_expired_tokens_and_sessions`()
BEGIN
    DECLARE sessions_deleted INT DEFAULT 0;
    DECLARE refresh_tokens_deleted INT DEFAULT 0;
    DECLARE email_tokens_deleted INT DEFAULT 0;
    DECLARE password_tokens_deleted INT DEFAULT 0;
    
    -- Delete expired or revoked sessions
    DELETE FROM `sessions` 
    WHERE `expires_at` < NOW() 
       OR `revoked_at` IS NOT NULL;
    SET sessions_deleted = ROW_COUNT();
    
    -- Delete expired or revoked refresh tokens
    DELETE FROM `refresh_tokens` 
    WHERE `expires_at` < NOW() 
       OR `revoked_at` IS NOT NULL;
    SET refresh_tokens_deleted = ROW_COUNT();
    
    -- Delete expired email verification tokens
    DELETE FROM `email_verification_tokens` 
    WHERE `expires_at` < NOW();
    SET email_tokens_deleted = ROW_COUNT();
    
    -- Delete expired password reset tokens
    DELETE FROM `password_reset_tokens` 
    WHERE `expires_at` < NOW();
    SET password_tokens_deleted = ROW_COUNT();
    
    -- Log the cleanup results
    SELECT 
        sessions_deleted AS sessions_cleaned,
        refresh_tokens_deleted AS refresh_tokens_cleaned,
        email_tokens_deleted AS email_tokens_cleaned,
        password_tokens_deleted AS password_tokens_cleaned,
        NOW() AS cleanup_executed_at;
END
;;
delimiter ;

-- ----------------------------
-- Event structure for event_cleanup_audit_logs
-- ----------------------------
DROP EVENT IF EXISTS `event_cleanup_audit_logs`;
delimiter ;;
CREATE EVENT `event_cleanup_audit_logs`
ON SCHEDULE
EVERY '1' MONTH STARTS '2025-11-13 02:00:00'
DO CALL cleanup_old_audit_logs()
;;
delimiter ;

-- ----------------------------
-- Event structure for event_cleanup_expired_tokens_and_sessions
-- ----------------------------
DROP EVENT IF EXISTS `event_cleanup_expired_tokens_and_sessions`;
delimiter ;;
CREATE EVENT `event_cleanup_expired_tokens_and_sessions`
ON SCHEDULE
EVERY '1' DAY STARTS '2025-11-13 02:00:00'
DO CALL cleanup_expired_tokens_and_sessions()
;;
delimiter ;

SET FOREIGN_KEY_CHECKS = 1;
