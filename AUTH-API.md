# Authentication API Documentation

Dokumentasi lengkap untuk semua endpoint authentication Laniakea SSO.

## Base URL

```
http://localhost:3000/api/v1/auth
```

## Endpoints

### 1. Login

Login user dengan username/email dan password.

**Endpoint:** `POST /api/v1/auth/login`

**Request Body:**

```json
{
  "usernameOrEmail": "johndoe",
  "password": "SecurePassword123!",
  "deviceName": "Chrome on Windows",
  "latitude": "-6.200000",
  "longitude": "106.816666",
  "rememberMe": true
}
```

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "a1b2c3d4e5f6g7h8i9j0...",
    "expiresIn": 3600,
    "tokenType": "Bearer",
    "rememberToken": "a1b2c3d4e5f6g7h8i9j0k1l2m3n4o5p6...",
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "name": "John Doe",
      "username": "johndoe",
      "email": "john@example.com",
      "phone": "+628123456789",
      "profilePhotoPath": "/uploads/avatar.jpg",
      "lastTenantId": "tenant-id",
      "lastServiceKey": "service-key"
    }
  },
  "timestamp": "2025-11-11T14:30:00.000Z"
}
```

**Request Fields:**

- `usernameOrEmail` (required): Username or email address
- `password` (required): User password (min 6 characters)
- `deviceName` (optional): Device name for session tracking (default: auto-detect from user agent)
- `latitude` (optional): GPS latitude for geolocation
- `longitude` (optional): GPS longitude for geolocation
- `rememberMe` (optional): Generate remember token for persistent login (default: false)

**Remember Me Feature:**

When `rememberMe: true`:

- Generates 64-character hex token
- Stored in `users.remember_token`
- Returned in response as `rememberToken`
- Frontend should store securely (httpOnly cookie recommended)
- Use for automatic re-authentication

**Error Responses:**

- `401 Unauthorized`: Invalid credentials
- `401 Unauthorized`: Account locked (permanent - contact support)
- `401 Unauthorized`: Account temporarily locked (5 or 15 minutes)
- `401 Unauthorized`: Account suspended (force logout active)
- `401 Unauthorized`: No active tenant relationship
- `401 Unauthorized`: All tenants inactive or revoked

**Progressive Lockout System:**

1. **First 5 Failed Attempts (1-5)**: Account locked for 5 minutes
   - Error: `"Invalid credentials. Account temporarily locked for 5 minutes. (Attempt X/5)"`
   - Audit event: `ACCOUNT_TEMPORARY_LOCK_5MIN`

2. **Second 5 Failed Attempts (6-10)**: Account locked for 15 minutes
   - Error: `"Account temporarily locked for 15 minutes due to multiple failed login attempts."`
   - Audit event: `ACCOUNT_TEMPORARY_LOCK_15MIN`

3. **11+ Failed Attempts**: Permanent lock + 24h force logout
   - Error: `"Account locked permanently due to too many failed login attempts. Please contact support."`
   - All sessions revoked immediately
   - Audit event: `ACCOUNT_PERMANENTLY_LOCKED`

**Features:**

- ✅ Access token valid for 1 hour
- ✅ Refresh token valid for 7 days
- ✅ Remember me token (optional, 64-char hex)
- ✅ Progressive lockout (5min → 15min → permanent)
- ✅ Tenant validation (active tenant required)
- ✅ Session creation with device tracking
- ✅ Geolocation support
- ✅ Comprehensive audit logging
- ✅ Auto-reset lockout after duration expires

---

### 2. Refresh Token

Refresh access token menggunakan refresh token.

**Endpoint:** `POST /api/v1/auth/refresh`

**Request Body:**

```json
{
  "refreshToken": "a1b2c3d4e5f6g7h8i9j0..."
}
```

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "b2c3d4e5f6g7h8i9j0k1...",
    "expiresIn": 3600,
    "tokenType": "Bearer"
  },
  "timestamp": "2025-11-11T14:30:00.000Z"
}
```

**Error Responses:**

- `401 Unauthorized`: Invalid refresh token
- `401 Unauthorized`: Refresh token revoked
- `401 Unauthorized`: Refresh token expired
- `401 Unauthorized`: Session terminated

**Features:**

- ✅ Token rotation (old token revoked)
- ✅ Session validation
- ✅ Automatic token expiry handling

---

### 3. Forgot Password

Request password reset link via email.

**Endpoint:** `POST /api/v1/auth/forgot-password`

**Request Body:**

```json
{
  "email": "john@example.com"
}
```

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "message": "If the email exists, a password reset link has been sent"
  },
  "timestamp": "2025-11-11T14:30:00.000Z"
}
```

**Features:**

- ✅ Email enumeration prevention (always returns success)
- ✅ Reset token expires in 60 minutes (configurable)
- ✅ Beautiful HTML email template
- ✅ Audit logging
- ✅ Rate limiting to prevent abuse

**Email Template:**
Email akan berisi:

- Personalized greeting
- Reset link button
- Plain text link for copy-paste
- Expiration warning
- Security notice

---

### 4. Reset Password

Reset password menggunakan token dari email.

**Endpoint:** `POST /api/v1/auth/reset-password`

**Request Body:**

```json
{
  "email": "john@example.com",
  "token": "abc123def456",
  "password": "NewPassword123!",
  "passwordConfirmation": "NewPassword123!"
}
```

**Password Requirements:**

- Minimal 8 karakter
- Harus mengandung huruf besar
- Harus mengandung huruf kecil
- Harus mengandung angka
- Harus mengandung karakter spesial (@$!%\*?&#)

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "message": "Password has been reset successfully. Please login with your new password."
  },
  "timestamp": "2025-11-11T14:30:00.000Z"
}
```

**Error Responses:**

- `400 Bad Request`: Passwords do not match
- `400 Bad Request`: Invalid or expired reset token
- `400 Bad Request`: Password doesn't meet requirements

**Features:**

- ✅ Strong password validation
- ✅ Token expiration check
- ✅ Automatic logout from all devices after reset
- ✅ All sessions revoked
- ✅ All refresh tokens revoked
- ✅ Audit logging

---

### 5. Logout

Logout dari device saat ini.

**Endpoint:** `POST /api/v1/auth/logout`

**Headers:**

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Request Body:**

```json
{}
```

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "message": "Successfully logged out"
  },
  "timestamp": "2025-11-11T14:30:00.000Z"
}
```

**Error Responses:**

- `401 Unauthorized`: No authorization header
- `401 Unauthorized`: Invalid token

**Features:**

- ✅ Revoke current session
- ✅ Revoke associated refresh tokens
- ✅ Audit logging
- ✅ JWT-based authentication required

---

### 6. Logout All

Logout dari semua devices.

**Endpoint:** `POST /api/v1/auth/logout-all`

**Headers:**

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Request Body:**

```json
{}
```

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "message": "Successfully logged out from all devices",
    "sessionsTerminated": 3
  },
  "timestamp": "2025-11-11T14:30:00.000Z"
}
```

**Error Responses:**

- `401 Unauthorized`: No authorization header
- `401 Unauthorized`: Invalid token

**Features:**

- ✅ Revoke ALL user sessions
- ✅ Revoke ALL refresh tokens
- ✅ Session count tracking

---

### 7. Send Email Verification

Kirim email verifikasi ke alamat email user.

**Endpoint:** `POST /api/v1/auth/send-email-verification`

**Request Body:**

```json
{
  "email": "john@example.com"
}
```

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "message": "Verification email sent successfully"
  },
  "timestamp": "2025-01-15T10:30:00.000Z"
}
```

**Error Responses:**

```json
{
  "success": false,
  "error": {
    "message": "Email not found",
    "reason": "email_not_found"
  },
  "timestamp": "2025-01-15T10:30:00.000Z"
}
```

```json
{
  "success": false,
  "error": {
    "message": "Email already verified",
    "reason": "email_already_verified"
  },
  "timestamp": "2025-01-15T10:30:00.000Z"
}
```

**Features:**

- ✅ Generates random 64-character token
- ✅ Token expires in 1 hour
- ✅ Replaces existing token if any (upsert)
- ✅ Sends HTML email with verification link
- ✅ Audit logging

---

### 8. Verify Email

Verifikasi alamat email menggunakan token dari email.

**Endpoint:** `POST /api/v1/auth/verify-email`

**Request Body:**

```json
{
  "email": "john@example.com",
  "token": "a1b2c3d4e5f6g7h8i9j0..."
}
```

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "message": "Email verified successfully"
  },
  "timestamp": "2025-01-15T10:30:00.000Z"
}
```

**Error Responses:**

```json
{
  "success": false,
  "error": {
    "message": "Invalid verification token",
    "reason": "invalid_verification_token"
  },
  "timestamp": "2025-01-15T10:30:00.000Z"
}
```

```json
{
  "success": false,
  "error": {
    "message": "Verification token has expired",
    "reason": "verification_token_expired"
  },
  "timestamp": "2025-01-15T10:30:00.000Z"
}
```

**Features:**

- ✅ Validates token matches email
- ✅ Checks token expiration (1 hour)
- ✅ Updates `email_verified_at` timestamp
- ✅ Deletes token after verification
- ✅ Audit logging

---

### 9. Switch Tenant

Pindah konteks ke tenant lain dan dapatkan access token baru.

**Endpoint:** `POST /api/v1/auth/switch-tenant`

**Headers:**

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Request Body:**

```json
{
  "tenantId": "550e8400-e29b-41d4-a716-446655440000"
}
```

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "message": "Successfully switched to tenant",
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "expiresIn": 3600,
    "tokenType": "Bearer",
    "tenant": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "name": "Acme Corporation",
      "code": "ACME",
      "logoPath": "/logos/acme.png",
      "status": "active"
    }
  },
  "timestamp": "2025-01-15T10:30:00.000Z"
}
```

**Error Responses:**

```json
{
  "success": false,
  "error": {
    "message": "You do not have access to this tenant",
    "reason": "tenant_access_denied"
  },
  "timestamp": "2025-01-15T10:30:00.000Z"
}
```

```json
{
  "success": false,
  "error": {
    "message": "Your access to this tenant is inactive",
    "reason": "tenant_access_inactive"
  },
  "timestamp": "2025-01-15T10:30:00.000Z"
}
```

```json
{
  "success": false,
  "error": {
    "message": "This tenant is inactive or has been revoked",
    "reason": "tenant_inactive_or_revoked"
  },
  "timestamp": "2025-01-15T10:30:00.000Z"
}
```

**Features:**

- ✅ Validates user has access to tenant
- ✅ Checks tenant relation is active
- ✅ Validates tenant is active and not revoked
- ✅ Updates `last_tenant_id` in users table
- ✅ Generates new access token with tenant context
- ✅ Returns tenant information
- ✅ Audit logging

**Frontend Flow:**

1. User clicks tenant switcher dropdown
2. Frontend calls `/switch-tenant` with target `tenantId`
3. Backend validates access and returns new token
4. Frontend replaces current access token
5. All subsequent requests use new tenant context

---

### 10. Toggle User Locked (Owner Only)

Lock atau unlock user account. Hanya tenant owner yang dapat melakukan aksi ini.

**Endpoint:** `POST /api/v1/auth/users/:id/toggle-locked`

**Headers:**

```
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
```

**Request Body:**

```json
{}
```

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "message": "User locked successfully",
    "userId": "550e8400-e29b-41d4-a716-446655440000",
    "isLocked": true,
    "lockedAt": "2025-01-15T10:30:00.000Z"
  },
  "timestamp": "2025-01-15T10:30:00.000Z"
}
```

```json
{
  "success": true,
  "data": {
    "message": "User unlocked successfully",
    "userId": "550e8400-e29b-41d4-a716-446655440000",
    "isLocked": false,
    "lockedAt": null
  },
  "timestamp": "2025-01-15T10:30:00.000Z"
}
```

**Error Responses:**

```json
{
  "success": false,
  "error": {
    "message": "No active tenant selected",
    "reason": "no_active_tenant"
  },
  "timestamp": "2025-01-15T10:30:00.000Z"
}
```

```json
{
  "success": false,
  "error": {
    "message": "Only tenant owners can lock/unlock users",
    "reason": "owner_permission_required"
  },
  "timestamp": "2025-01-15T10:30:00.000Z"
}
```

```json
{
  "success": false,
  "error": {
    "message": "User not found",
    "reason": "user_not_found"
  },
  "timestamp": "2025-01-15T10:30:00.000Z"
}
```

**Features:**

- ✅ Owner-only permission (checks `TenantHasUser.isOwner`)
- ✅ Toggles `is_locked` status
- ✅ Updates `locked_at` timestamp
- ✅ Revokes all user sessions when locking
- ✅ Resets lockout counters when unlocking
- ✅ Audit logging with old/new values

**Permission Logic:**

1. Get current user's `last_tenant_id`
2. Query `TenantHasUser` where `userId=currentUser` AND `tenantId=lastTenantId`
3. Check if `isOwner = true`
4. If not owner, throw `owner_permission_required`

**Behavior on Lock:**

- Sets `is_locked = true`
- Sets `locked_at = NOW()`
- Revokes all user sessions (commented until Prisma generate)

**Behavior on Unlock:**

- Sets `is_locked = false`
- Sets `locked_at = NULL`
- Resets `failed_login_counter = 0`
- Clears `temporary_lock_until = NULL`
- Clears `force_logout_at = NULL`

---

- ✅ Audit logging
- ✅ Useful for security incidents

---

## Security Features

### 1. Account Locking

- Account dikunci setelah 5 kali failed login (configurable)
- Logged in audit trail
- Admin notification (future enhancement)

### 2. Session Management

- Session tracking per device
- IP address & user agent recording
- Geolocation support
- Last activity tracking

### 3. Token Security

- JWT access token (1 hour expiration)
- Refresh token rotation
- Refresh token hashing (SHA-256)
- Token revocation support

### 4. Audit Logging

Semua operasi tercatat dalam `audit_logs`:

- User login
- User logout
- Failed login attempts
- Password reset requests
- Password changes
- Token refresh
- Account locking
- Logout all devices

### 5. Password Security

- Bcrypt hashing (10 rounds)
- Strong password validation
- Password reset with email verification
- Force logout after password change

---

## cURL Examples

### Login

```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "usernameOrEmail": "johndoe",
    "password": "SecurePassword123!",
    "deviceName": "Chrome on Windows"
  }'
```

### Refresh Token

```bash
curl -X POST http://localhost:3000/api/v1/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{
    "refreshToken": "your-refresh-token-here"
  }'
```

### Forgot Password

```bash
curl -X POST http://localhost:3000/api/v1/auth/forgot-password \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com"
  }'
```

### Reset Password

```bash
curl -X POST http://localhost:3000/api/v1/auth/reset-password \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john@example.com",
    "token": "reset-token-from-email",
    "password": "NewPassword123!",
    "passwordConfirmation": "NewPassword123!"
  }'
```

### Logout

```bash
curl -X POST http://localhost:3000/api/v1/auth/logout \
  -H "Authorization: Bearer your-access-token-here"
```

### Logout All

```bash
curl -X POST http://localhost:3000/api/v1/auth/logout-all \
  -H "Authorization: Bearer your-access-token-here"
```

---

## Environment Variables

```bash
# JWT Configuration
JWT_SECRET=your-super-secret-jwt-key
JWT_EXPIRES_IN=1h
JWT_REFRESH_EXPIRES_IN=7d

# Security
MAX_FAILED_LOGIN_ATTEMPTS=5
PASSWORD_RESET_EXPIRATION_MINUTES=60
SESSION_TIMEOUT_MINUTES=60

# Frontend URL
FRONTEND_URL=http://localhost:3000

# Email (untuk forgot password)
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USER=your-email@gmail.com
MAIL_PASSWORD=your-app-password
MAIL_FROM="Laniakea SSO <noreply@laniakea.com>"
```

---

## Database Tables Used

### users

- User credentials
- Account status (locked, deleted)
- Last login tracking

### sessions

- Active user sessions
- Device tracking
- Geolocation data

### refresh_tokens

- Refresh token hashes
- Token expiration
- Revocation status

### password_reset_tokens

- Email-token mapping
- Token expiration

### failed_login_attempts

- Failed login tracking
- IP address & user agent
- Brute force prevention

### audit_logs

- Comprehensive audit trail
- All authentication events

---

## Testing

### 1. Test Login

```typescript
// Successful login
POST /api/v1/auth/login
{
  "usernameOrEmail": "testuser",
  "password": "Test123!@#"
}

// Expected: 200 OK with tokens
```

### 2. Test Failed Login

```typescript
// Wrong password
POST /api/v1/auth/login
{
  "usernameOrEmail": "testuser",
  "password": "wrongpassword"
}

// Expected: 401 Unauthorized
```

### 3. Test Account Locking

```typescript
// Try 5 times with wrong password
// 6th attempt should return account locked
```

### 4. Test Token Refresh

```typescript
// Use refresh token from login
POST /api/v1/auth/refresh
{
  "refreshToken": "..."
}

// Expected: 200 OK with new tokens
```

### 5. Test Password Reset Flow

```typescript
// 1. Request reset
POST /api/v1/auth/forgot-password
{ "email": "test@example.com" }

// 2. Get token from email/logs
// 3. Reset password
POST /api/v1/auth/reset-password
{
  "email": "test@example.com",
  "token": "...",
  "password": "NewPass123!",
  "passwordConfirmation": "NewPass123!"
}

// Expected: 200 OK, all sessions revoked
```

---

## Common Error Codes

| Code | Description                              |
| ---- | ---------------------------------------- |
| 200  | Success                                  |
| 400  | Bad Request (validation error)           |
| 401  | Unauthorized (invalid credentials/token) |
| 403  | Forbidden (account locked/suspended)     |
| 429  | Too Many Requests (rate limiting)        |
| 500  | Internal Server Error                    |

---

## 11. Get Active Sessions (Device Management)

Get all active sessions/devices for current user.

**Endpoint:** `GET /api/v1/auth/sessions`

**Headers:**

```
Authorization: Bearer <access_token>
```

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "message": "Active sessions retrieved successfully",
    "sessions": [
      {
        "id": "550e8400-e29b-41d4-a716-446655440001",
        "deviceName": "Chrome on Windows",
        "ipAddress": "192.168.1.100",
        "userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)...",
        "lastActivity": "2025-11-12T14:30:00Z",
        "createdAt": "2025-11-10T08:00:00Z",
        "isCurrent": true
      },
      {
        "id": "550e8400-e29b-41d4-a716-446655440002",
        "deviceName": "Safari on iPhone",
        "ipAddress": "10.0.0.5",
        "userAgent": "Mozilla/5.0 (iPhone; CPU iPhone OS 14_0...)...",
        "lastActivity": "2025-11-11T10:15:00Z",
        "createdAt": "2025-11-09T12:00:00Z",
        "isCurrent": false
      }
    ]
  },
  "timestamp": "2025-11-12T14:35:00.000Z"
}
```

**Response Fields:**

- `id`: Session/device ID
- `deviceName`: Device name (browser + OS)
- `ipAddress`: IP address of the device
- `userAgent`: Full user agent string
- `lastActivity`: Last time this session was used
- `createdAt`: When session was created (login time)
- `isCurrent`: Whether this is the current session

**Error Responses:**

- `401 Unauthorized`: Invalid or missing token

**Use Cases:**

- Show list of logged-in devices
- Allow user to see where they're logged in
- Identify suspicious sessions

---

## 12. Revoke Session (Force Logout Device)

Revoke a specific session to force logout on that device.

**Endpoint:** `DELETE /api/v1/auth/sessions/:id`

**Headers:**

```
Authorization: Bearer <access_token>
```

**URL Parameters:**

- `id` (required): Session ID to revoke

**Example:**

```
DELETE /api/v1/auth/sessions/550e8400-e29b-41d4-a716-446655440002
```

**Response (200 OK):**

```json
{
  "success": true,
  "data": {
    "message": "Session revoked successfully"
  },
  "timestamp": "2025-11-12T14:40:00.000Z"
}
```

**What Happens:**

1. Session marked as revoked (`revokedAt` timestamp set)
2. All refresh tokens for that session are revoked
3. User will be forced to login again on that device
4. Audit log created for security tracking

**Error Responses:**

```json
{
  "success": false,
  "error": {
    "message": "Session not found or does not belong to you",
    "reason": "session_not_found"
  },
  "timestamp": "2025-11-12T14:40:00.000Z"
}
```

```json
{
  "success": false,
  "error": {
    "message": "Session already revoked",
    "reason": "session_already_revoked"
  },
  "timestamp": "2025-11-12T14:40:00.000Z"
}
```

- `400 Bad Request`: Session not found or already revoked
- `401 Unauthorized`: Invalid or missing token

**Use Cases:**

- Logout from specific device remotely
- Remove access from lost/stolen device
- Security: Revoke suspicious sessions

---

## JWT Token Security Model

### New Session-Based JWT Strategy

Untuk keamanan, JWT **tidak lagi menyimpan data user lengkap**. Sebagai gantinya:

**JWT Payload (Access Token):**

```json
{
  "session_id": "550e8400-e29b-41d4-a716-446655440001",
  "type": "access",
  "iat": 1699876543,
  "exp": 1699880143
}
```

**Flow:**

1. **Login** → Create session → JWT berisi `session_id` saja
2. **Request with JWT** → Middleware extract `session_id` → Query `sessions` table → Check `revoked_at`
3. **If `revoked_at` NOT NULL** → Return `401 Unauthorized` (session revoked, login ulang)
4. **If valid** → Fetch full user data → Attach to request

**Keuntungan:**

- ✅ **Security**: Data user tidak exposed di JWT
- ✅ **Instant Revocation**: Revoke session langsung efektif (tidak perlu tunggu token expire)
- ✅ **Device Management**: Track & manage semua device yang login
- ✅ **Flexibility**: Update user data tidak perlu regenerate token

**Refresh Token:**

- Tetap menggunakan SHA-256 hashed token di database
- Token rotation: setiap refresh, token lama di-revoke, token baru dibuat
- Expiration: 7 hari (configurable)

---

## Best Practices

1. **Token Storage (Client-side)**
   - Store access token in memory or sessionStorage
   - Store refresh token in httpOnly cookie (recommended) or localStorage
   - Never store tokens in plain localStorage if possible

2. **Token Refresh**
   - Implement automatic token refresh before expiration
   - Handle 401 errors gracefully (especially `session_revoked`)
   - Retry failed requests after token refresh
   - If `reason: "session_revoked"` → Force logout dan redirect ke login

3. **Device Management**
   - Show active sessions in user settings
   - Allow users to revoke suspicious sessions
   - Highlight current device with `isCurrent: true`

4. **Password Reset**
   - Always validate email on client-side
   - Show consistent message to prevent email enumeration
   - Implement CAPTCHA for forgot password (future enhancement)

5. **Logout**
   - Always call logout endpoint on user logout
   - Clear all tokens from storage
   - Redirect to login page

6. **Security**
   - Use HTTPS in production
   - Implement CSRF protection
   - Add rate limiting
   - Monitor audit logs for suspicious activity
   - Implement session timeout (auto-revoke after X days inactive)

---

## Next Steps

1. ✅ Schema created
2. ✅ All endpoints implemented
3. ✅ Audit logging integrated
4. ✅ Email service ready
5. ✅ Session-based JWT security implemented
6. ✅ Device management endpoints added
7. ⏳ Run database migration: `mysql -u root -p lania_sso < sso.sql`
8. ⏳ Generate Prisma client: `npx prisma generate`
9. ⏳ Install dependencies: `npm install bcrypt uuid`
10. ⏳ Test all endpoints
11. ⏳ Configure email SMTP for production
12. ⏳ Add Swagger documentation (optional)

---

## Contact & Support

For issues or questions, please contact the development team.

© 2025 Laniakea SSO. All rights reserved.
