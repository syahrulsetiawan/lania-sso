# Email Verification & New Features Migration Guide

This guide documents the implementation of email verification, tenant switching, user locking, and remember me features.

## Database Changes

### New Table: email_verification_tokens

```sql
CREATE TABLE IF NOT EXISTS `email_verification_tokens` (
  `email` VARCHAR(191) NOT NULL,
  `token` VARCHAR(255) NOT NULL,
  `expires_at` TIMESTAMP NOT NULL,
  `created_at` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`email`),
  INDEX `idx_token` (`token`),
  INDEX `idx_expires_at` (`expires_at`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

**Purpose**: Stores email verification tokens with 1-hour expiration.

## Migration Steps

### 1. Import Updated Database Schema

```bash
# Backup existing database
mysqldump -u root -p laniakea_sso > backup_before_new_features.sql

# Import updated schema
mysql -u root -p laniakea_sso < sso.sql
```

### 2. Generate Prisma Client

```bash
npx prisma generate
```

This will generate types for the new `EmailVerificationToken` model.

### 3. Uncomment Code (After Prisma Generate)

No code to uncomment - all emailVerificationToken queries are already active.

## New Features

### 1. Email Verification

**Send Verification Email**

```http
POST /api/v1/auth/send-email-verification
Content-Type: application/json

{
  "email": "user@example.com"
}
```

**Response:**

```json
{
  "message": "Verification email sent successfully"
}
```

**Error Codes:**

- `email_not_found` - Email doesn't exist in system
- `email_already_verified` - Email is already verified

**Verify Email**

```http
POST /api/v1/auth/verify-email
Content-Type: application/json

{
  "email": "user@example.com",
  "token": "abc123def456..."
}
```

**Response:**

```json
{
  "message": "Email verified successfully"
}
```

**Error Codes:**

- `invalid_verification_token` - Token doesn't match or not found
- `verification_token_expired` - Token expired (>1 hour old)

### 2. Switch Tenant

**Endpoint:**

```http
POST /api/v1/auth/switch-tenant
Authorization: Bearer <access_token>
Content-Type: application/json

{
  "tenantId": "550e8400-e29b-41d4-a716-446655440000"
}
```

**Response:**

```json
{
  "message": "Successfully switched to tenant",
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expiresIn": 3600,
  "tokenType": "Bearer",
  "tenant": {
    "id": "550e8400-e29b-41d4-a716-446655440000",
    "name": "Acme Corp",
    "code": "ACME",
    "logoPath": "/logos/acme.png",
    "status": "active"
  }
}
```

**Error Codes:**

- `tenant_access_denied` - User doesn't have access to tenant
- `tenant_access_inactive` - User's access to tenant is inactive
- `tenant_inactive_or_revoked` - Tenant is inactive or revoked

**Flow:**

1. Validates user has `TenantHasUser` relation with `isActive=true`
2. Validates tenant is active and not revoked
3. Updates `users.last_tenant_id`
4. Generates new access token with tenant context
5. Returns new token to use for subsequent requests

### 3. Toggle User Locked (Owner Only)

**Endpoint:**

```http
POST /api/v1/auth/users/:id/toggle-locked
Authorization: Bearer <access_token>
```

**Response:**

```json
{
  "message": "User locked successfully",
  "userId": "550e8400-e29b-41d4-a716-446655440000",
  "isLocked": true,
  "lockedAt": "2024-01-15T10:30:00.000Z"
}
```

**Error Codes:**

- `no_active_tenant` - Current user has no tenant selected
- `owner_permission_required` - Only tenant owners can lock/unlock
- `user_not_found` - Target user doesn't exist

**Permissions:**

- Only users with `TenantHasUser.isOwner = true` can toggle lock
- Based on current user's `last_tenant_id`

**Behavior:**

- **When Locking:**
  - Sets `is_locked = true`
  - Sets `locked_at = NOW()`
  - Revokes all user sessions (commented until Prisma generate)
- **When Unlocking:**
  - Sets `is_locked = false`
  - Sets `locked_at = NULL`
  - Resets `failed_login_counter = 0`
  - Clears `temporary_lock_until = NULL`
  - Clears `force_logout_at = NULL`

### 4. Remember Me

**Login with Remember Me:**

```http
POST /api/v1/auth/login
Content-Type: application/json

{
  "usernameOrEmail": "johndoe",
  "password": "SecurePassword123!",
  "rememberMe": true
}
```

**Response:**

```json
{
  "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "expiresIn": 3600,
  "tokenType": "Bearer",
  "rememberToken": "a1b2c3d4e5f6...",
  "user": { ... }
}
```

**Behavior:**

- When `rememberMe=true`, generates 64-character hex token
- Stores in `users.remember_token`
- Frontend can store this token for automatic re-authentication
- Token persists until user explicitly logs out

**Security Note:**

- Remember tokens should be stored securely (httpOnly cookies recommended)
- Clear remember token on logout-all
- Rotate token on password change

## Email Templates

### Email Verification Template

HTML email with:

- Green header with "Verify Your Email Address"
- Personalized greeting
- Prominent "Verify Email" button
- Copy-paste link fallback
- 1-hour expiration warning
- Automated footer

**Frontend Integration:**

```typescript
// Email verification URL format
const url = `${FRONTEND_URL}/verify-email?token=${token}&email=${encodeURIComponent(email)}`;

// Frontend should POST to /api/v1/auth/verify-email with token and email
```

## Audit Logging

All new features include comprehensive audit logging:

**Email Verification:**

- `send_email_verification` - When verification email sent
- `email_verified` - When email successfully verified

**Tenant Switching:**

- `switch_tenant` - Records tenant switch with old/new tenant IDs

**User Locking:**

- `user_locked` - When owner locks a user
- `user_unlocked` - When owner unlocks a user

## Testing Scenarios

### Email Verification

```bash
# Send verification
curl -X POST http://localhost:3000/api/v1/auth/send-email-verification \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com"}'

# Verify email
curl -X POST http://localhost:3000/api/v1/auth/verify-email \
  -H "Content-Type: application/json" \
  -d '{"email":"test@example.com","token":"TOKEN_FROM_EMAIL"}'
```

### Switch Tenant

```bash
curl -X POST http://localhost:3000/api/v1/auth/switch-tenant \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"tenantId":"TENANT_UUID"}'
```

### Toggle User Locked

```bash
curl -X POST http://localhost:3000/api/v1/auth/users/USER_UUID/toggle-locked \
  -H "Authorization: Bearer OWNER_ACCESS_TOKEN"
```

### Remember Me Login

```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "usernameOrEmail":"johndoe",
    "password":"SecurePassword123!",
    "rememberMe":true
  }'
```

## Rollback Procedure

If issues occur:

```sql
-- Drop email verification table
DROP TABLE IF EXISTS email_verification_tokens;

-- Remove remember tokens
UPDATE users SET remember_token = NULL;
```

Then revert to previous Prisma schema and regenerate client.

## Frontend Integration Checklist

- [ ] Implement email verification flow (send → verify)
- [ ] Add tenant switcher dropdown in header
- [ ] Add owner-only user management page with lock/unlock
- [ ] Implement "Remember Me" checkbox on login form
- [ ] Store remember token securely (httpOnly cookie)
- [ ] Update error handling for new reason codes
- [ ] Add translations for new error messages

## Security Considerations

1. **Email Verification:**
   - Tokens expire after 1 hour
   - One token per email (upsert replaces old tokens)
   - Token stored in plain text (consider hashing for production)

2. **Tenant Switching:**
   - Validates user has active access to target tenant
   - New JWT includes tenant context
   - Old tokens remain valid until expiration

3. **User Locking:**
   - Owner-only permission enforced
   - Revokes all sessions on lock
   - Resets all lockout counters on unlock

4. **Remember Me:**
   - 64-character random token
   - Stored in database (consider encryption)
   - Should be cleared on security events

## Next Steps

1. Import updated `sso.sql`
2. Run `npx prisma generate`
3. Test all 4 new endpoints
4. Update frontend to integrate new features
5. Configure email provider (SendGrid, AWS SES, etc.)
6. Update user documentation
