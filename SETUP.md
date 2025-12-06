# Laniakea SSO - Setup Instructions (PostgreSQL)

Panduan lengkap untuk setup dan menjalankan Laniakea SSO Authentication System dengan PostgreSQL.

## ✅ Status Implementasi

Semua fitur authentication sudah **SELESAI** diimplementasikan:

- ✅ **Prisma Schema** - Sudah disesuaikan dengan `sso.sql` Anda
- ✅ **Login Endpoint** - Access token (1 jam) + Refresh token
- ✅ **Refresh Endpoint** - Token rotation
- ✅ **Forgot Password** - Kirim email reset password
- ✅ **Reset Password** - Reset dengan token dari email
- ✅ **Logout** - Logout dari device saat ini
- ✅ **Logout All** - Logout dari semua devices
- ✅ **Audit Logging** - Semua operasi tercatat
- ✅ **Email Service** - Template HTML untuk password reset
- ✅ **Security Features** - Account locking, session management, token rotation

---

## 📦 Step 1: Install Dependencies

Install package yang diperlukan:

```powershell
npm install uuid
npm install -D @types/uuid
```

**Note:** `bcryptjs` sudah ada di package.json, tidak perlu install lagi.

**Optional (untuk Swagger API documentation):**

```powershell
npm install @nestjs/swagger
```

---

## 🗄️ Step 2: Setup Database

### 2.1 Create Database

Buat database terlebih dahulu:

```powershell
# Buat database lania_sso
psql -U postgres << EOF
CREATE DATABASE lania_sso LOCALE_PROVIDER = 'libc' LOCALE = 'en_US.UTF-8' TEMPLATE template0;
CREATE DATABASE lania_common LOCALE_PROVIDER = 'libc' LOCALE = 'en_US.UTF-8' TEMPLATE template0;
EOF
```

### 2.2 Import Database Schema

Jalankan file SQL yang sudah ada:

```powershell
# Import schema untuk lania_sso
psql -U postgres -d lania_sso -f lania_sso_postgres.sql

# Import schema untuk lania_common
psql -U postgres -d lania_common -f lania_common_postgres.sql
```

**Note:** Database akan terisi dengan extensions, tables, functions, dan demo data.

### 2.2 Generate Prisma Client

Generate TypeScript types dari Prisma schema:

```powershell
npx prisma generate
```

---

## ⚙️ Step 3: Configure Environment

### 3.1 Copy Environment File

```powershell
Copy-Item .env.example .env
```

### 3.2 Edit `.env` File

Buka `.env` dan sesuaikan konfigurasi:

```bash
# Database - Sesuaikan dengan PostgreSQL Anda
DATABASE_URL="postgresql://postgres:password@localhost:5432/lania_sso?schema=public"

# JWT Secret - GANTI dengan secret yang kuat
JWT_SECRET=ganti-dengan-secret-yang-sangat-panjang-dan-random-minimal-32-karakter

# Email (jika sudah siap untuk production)
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USER=your-email@gmail.com
MAIL_PASSWORD=your-app-password
MAIL_FROM="Laniakea SSO <noreply@laniakea.com>"

# Frontend URL (untuk link reset password)
FRONTEND_URL=http://localhost:3000
```

---

## 🚀 Step 4: Run Application

### Development Mode

```powershell
npm run start:dev
```

### Production Mode

```powershell
npm run build
npm run start:prod
```

Server akan berjalan di: **http://localhost:3000**

---

## 🧪 Step 5: Test Endpoints

### Test dengan cURL

#### 1. Test Login

```powershell
curl -X POST http://localhost:3000/api/v1/auth/login `
  -H "Content-Type: application/json" `
  -d '{\"usernameOrEmail\":\"testuser\",\"password\":\"Test123!\"}'
```

#### 2. Test Refresh Token

```powershell
curl -X POST http://localhost:3000/api/v1/auth/refresh `
  -H "Content-Type: application/json" `
  -d '{\"refreshToken\":\"your-refresh-token-here\"}'
```

#### 3. Test Forgot Password

```powershell
curl -X POST http://localhost:3000/api/v1/auth/forgot-password `
  -H "Content-Type: application/json" `
  -d '{\"email\":\"test@example.com\"}'
```

#### 4. Test Logout

```powershell
curl -X POST http://localhost:3000/api/v1/auth/logout `
  -H "Authorization: Bearer your-access-token-here"
```

---

## 📊 Database Verification

Cek apakah semua tabel sudah ada:

```powershell
psql -U postgres -d lania_sso -c "\dt"
```

Expected tables:

- users
- sessions
- refresh_tokens
- password_reset_tokens
- email_verification_tokens
- failed_login_attempts
- audit_logs
- tenants
- tenant_has_user
- tenant_has_service
- user_configs
- tenant_configs
- tenant_licenses
- core_licenses
- core_services
- core_status_tenants
- default_values
- tenant_connections

---

## 🔐 Create Test User

Buat user untuk testing:

```sql
INSERT INTO users (
  id, name, username, email, password, created_at, updated_at
) VALUES (
  UUID(),
  'Test User',
  'testuser',
  'test@example.com',
  '$2b$10$YourBcryptHashedPasswordHere',
  NOW(),
  NOW()
);
```

**Generate password hash:**

```javascript
// Jalankan di Node.js console
const bcrypt = require('bcrypt');
bcrypt.hash('Test123!', 10, (err, hash) => {
  console.log(hash);
});
```

---

## 📝 API Documentation

Lihat dokumentasi lengkap di **`AUTH-API.md`**.

Semua endpoint:

- `POST /api/v1/auth/login` - Login user
- `POST /api/v1/auth/refresh` - Refresh access token
- `POST /api/v1/auth/forgot-password` - Request password reset
- `POST /api/v1/auth/reset-password` - Reset password
- `POST /api/v1/auth/logout` - Logout dari device ini
- `POST /api/v1/auth/logout-all` - Logout dari semua devices

---

## 🔍 Debugging

### Check Logs

```powershell
# Development logs
Get-Content logs/application.log -Tail 50

# Error logs
Get-Content logs/error.log -Tail 50
```

### Check Audit Logs

```powershell
psql -U postgres -d lania_sso -c "SELECT * FROM audit_logs ORDER BY created_at DESC LIMIT 20;"
```

### Check Active Sessions

```powershell
psql -U postgres -d lania_sso -c "SELECT s.*, u.username, u.email FROM sessions s JOIN users u ON s.user_id = u.id WHERE s.revoked_at IS NULL ORDER BY s.last_activity DESC;"
```

### Check Failed Login Attempts

```powershell
psql -U postgres -d lania_sso -c "SELECT * FROM failed_login_attempts ORDER BY attempted_at DESC LIMIT 20;"
```

---

## 🛠️ Troubleshooting

### Error: Cannot find module 'uuid'

```powershell
npm install uuid
npm install -D @types/uuid
```

### Error: Prisma Client not found

```powershell
npx prisma generate
```

### Error: Database connection failed

- Cek DATABASE_URL di `.env`
- Pastikan PostgreSQL running
- Cek username/password PostgreSQL

### Error: JWT secret not configured

- Set JWT_SECRET di `.env`
- Minimal 32 karakter untuk keamanan

---

## 📧 Email Configuration

### Development (Log only)

Saat development, email tidak benar-benar dikirim. Reset password link akan muncul di logs:

```
[AuthService] === PASSWORD RESET EMAIL ===
To: test@example.com
Reset URL: http://localhost:3000/reset-password?token=abc123&email=test%40example.com
```

### Production (Real SMTP)

Edit `src/auth/email.service.ts`:

Uncomment bagian nodemailer dan install package:

```powershell
npm install nodemailer @types/nodemailer
```

Configure `.env`:

```bash
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USER=your-email@gmail.com
MAIL_PASSWORD=your-app-password  # Use App Password for Gmail
MAIL_FROM="Laniakea SSO <noreply@laniakea.com>"
MAIL_SECURE=false
```

---

## 🔒 Security Checklist

- [x] JWT secret menggunakan minimum 32 karakter random
- [x] Password hashing dengan bcrypt (10 rounds)
- [x] Account locking after 5 failed attempts
- [x] Refresh token rotation (old token revoked)
- [x] Session management dengan device tracking
- [x] Comprehensive audit logging
- [x] Password strength validation
- [x] Email enumeration prevention
- [ ] HTTPS in production (setup di reverse proxy)
- [ ] Rate limiting (sudah diaktifkan di main.ts)
- [ ] CORS configuration (sesuaikan dengan frontend URL)

---

## 📁 Project Structure

```
src/
├── auth/
│   ├── dto/
│   │   ├── login.dto.ts           # Login request/response
│   │   ├── refresh-token.dto.ts   # Refresh token request/response
│   │   ├── password-reset.dto.ts  # Forgot/reset password DTOs
│   │   ├── logout.dto.ts          # Logout responses
│   │   └── index.ts               # Barrel export
│   ├── auth.controller.ts         # 6 endpoints
│   ├── auth.service.ts            # Business logic
│   ├── auth.module.ts             # Module configuration
│   └── email.service.ts           # Email sending
├── audit/
│   ├── audit.service.ts           # Audit logging
│   ├── audit.module.ts
│   └── ...
├── prisma/
│   ├── prisma.service.ts          # Database connection
│   └── prisma.module.ts
└── common/
    ├── guards/
    │   └── jwt-auth.guard.ts      # JWT authentication guard
    ├── filters/
    │   └── http-exception.filter.ts
    └── interceptors/
        └── response.interceptor.ts
```

---

## 📚 Next Features (Optional)

1. **Email Verification**
   - Verify email setelah registrasi
   - Resend verification email

2. **Two-Factor Authentication (2FA)**
   - TOTP dengan Google Authenticator
   - SMS OTP

3. **OAuth Integration**
   - Google OAuth
   - Facebook Login
   - GitHub OAuth

4. **Session Management Dashboard**
   - View active sessions
   - Revoke specific session
   - Device history

5. **Security Enhancements**
   - CAPTCHA untuk forgot password
   - IP whitelist/blacklist
   - Suspicious activity detection
   - Brute force protection

6. **Swagger Documentation**
   - Install @nestjs/swagger
   - Auto-generate API docs
   - Interactive testing

---

## 🎯 Quick Start Summary

```powershell
# 1. Install dependencies
npm install uuid
npm install -D @types/uuid

# 2. Setup database
psql -U postgres << EOF
CREATE DATABASE lania_sso LOCALE_PROVIDER = 'libc' LOCALE = 'en_US.UTF-8' TEMPLATE template0;
CREATE DATABASE lania_common LOCALE_PROVIDER = 'libc' LOCALE = 'en_US.UTF-8' TEMPLATE template0;
EOF
psql -U postgres -d lania_sso -f lania_sso_postgres.sql
psql -U postgres -d lania_common -f lania_common_postgres.sql

# 3. Generate Prisma client
npx prisma generate

# 4. Configure environment
Copy-Item .env.example .env
# Edit .env file

# 5. Run application
npm run start:dev

# 6. Test login endpoint
curl -X POST http://localhost:8001/api/v1/auth/login -H "Content-Type: application/json" -d '{\"usernameOrEmail\":\"superadmin\",\"password\":\"password\",\"deviceName\":\"Test Device\"}'
```

---

## ✨ Completed!

Semua endpoint authentication sudah **ready to use**:

✅ Login dengan access token (1 jam) + refresh token  
✅ Refresh token dengan token rotation  
✅ Forgot password dengan email  
✅ Reset password dengan validasi kuat  
✅ Logout dari device saat ini  
✅ Logout dari semua devices  
✅ Comprehensive audit logging untuk semua operasi

**Happy Coding! 🚀**

---

## 📞 Support

Jika ada pertanyaan atau issue, silakan hubungi tim development.

© 2025 Laniakea. All rights reserved.
