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
  "longitude": "106.816666"
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

## Best Practices

1. **Token Storage (Client-side)**
   - Store access token in memory or sessionStorage
   - Store refresh token in httpOnly cookie (recommended) or localStorage
   - Never store tokens in plain localStorage if possible

2. **Token Refresh**
   - Implement automatic token refresh before expiration
   - Handle 401 errors gracefully
   - Retry failed requests after token refresh

3. **Password Reset**
   - Always validate email on client-side
   - Show consistent message to prevent email enumeration
   - Implement CAPTCHA for forgot password (future enhancement)

4. **Logout**
   - Always call logout endpoint on user logout
   - Clear all tokens from storage
   - Redirect to login page

5. **Security**
   - Use HTTPS in production
   - Implement CSRF protection
   - Add rate limiting
   - Monitor audit logs for suspicious activity

---

## Next Steps

1. ✅ Schema created
2. ✅ All endpoints implemented
3. ✅ Audit logging integrated
4. ✅ Email service ready
5. ⏳ Run database migration: `mysql -u root -p lania_sso < sso.sql`
6. ⏳ Generate Prisma client: `npx prisma generate`
7. ⏳ Install dependencies: `npm install bcrypt uuid`
8. ⏳ Test all endpoints
9. ⏳ Configure email SMTP for production
10. ⏳ Add Swagger documentation (optional)

---

## Contact & Support

For issues or questions, please contact the development team.

© 2025 Laniakea SSO. All rights reserved.
