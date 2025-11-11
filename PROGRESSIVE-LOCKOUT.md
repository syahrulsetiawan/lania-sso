# Progressive Lockout System

## Overview

Progressive lockout system untuk melindungi akun dari brute force attacks dengan meningkatkan durasi lockout secara bertahap.

## Lockout Levels

### Level 1: First 5 Failed Attempts (1-5)

- **Duration**: 5 minutes temporary lock
- **Trigger**: Setelah password salah 1-5 kali
- **Behavior**:
  - User tidak bisa login selama 5 menit dari percobaan terakhir
  - Counter tidak di-reset, terus bertambah
  - Error message: `"Invalid credentials. Account temporarily locked for 5 minutes. (Attempt X/5)"`
  - Audit event: `ACCOUNT_TEMPORARY_LOCK_5MIN`

### Level 2: Second 5 Failed Attempts (6-10)

- **Duration**: 15 minutes temporary lock
- **Trigger**: Setelah password salah 6-10 kali
- **Behavior**:
  - User tidak bisa login selama 15 menit dari percobaan terakhir
  - Counter tidak di-reset, terus bertambah
  - Error message: `"Account temporarily locked for 15 minutes due to multiple failed login attempts."`
  - Audit event: `ACCOUNT_TEMPORARY_LOCK_15MIN`

### Level 3: Third Set (11+ attempts)

- **Duration**: Permanent lock + 24 hours force logout
- **Trigger**: Setelah password salah 11 kali atau lebih
- **Behavior**:
  - Account di-lock permanen (`is_locked = true`)
  - `force_logout_at` di-set 24 jam dari sekarang
  - Semua session di-revoke
  - User **HARUS** contact support untuk unlock
  - Error message: `"Account locked permanently due to too many failed login attempts. Please contact support."`
  - Audit event: `ACCOUNT_PERMANENTLY_LOCKED`

## Database Schema

```sql
ALTER TABLE users ADD COLUMN temporary_lock_until TIMESTAMP NULL;
```

### New Fields:

- `temporary_lock_until`: Waktu sampai kapan account di-lock sementara
- `failed_login_counter`: Counter untuk tracking jumlah percobaan gagal
- `is_locked`: Boolean permanent lock (hanya bisa di-unlock oleh admin)
- `force_logout_at`: Timestamp untuk force logout semua session

## JWT Guard Protection

JWT Authentication Guard (`jwt-auth.guard.ts`) sekarang mengecek:

1. ✅ **User Exists**: Apakah user masih ada dan tidak deleted
2. ✅ **Permanent Lock**: Apakah `is_locked = true`
3. ✅ **Temporary Lock**: Apakah `temporary_lock_until > now()`
4. ✅ **Force Logout**: Apakah `force_logout_at > now()`

### Error Response Examples:

```json
// Permanent Lock
{
  "message": "Your account has been locked. Please contact support.",
  "reason": "account_locked"
}

// Temporary Lock
{
  "message": "Account temporarily locked. Try again in 12 minute(s).",
  "reason": "temporary_lock",
  "lockedUntil": "2025-11-11T10:30:00.000Z"
}

// Force Logout
{
  "message": "Your account is temporarily suspended.",
  "reason": "force_logout"
}
```

## Login Flow

```
1. User enters credentials
2. Check if user exists
3. Check if is_locked = true → REJECT (permanent)
4. Check if temporary_lock_until > now() → REJECT (show minutes remaining)
5. Check if temporary_lock_until ≤ now() → RESET counter & temporary_lock_until
6. Verify password
   ├─ CORRECT → Reset failedLoginCounter to 0, login success
   └─ WRONG → Increment failedLoginCounter
       ├─ 1-5 attempts → Lock 5 minutes
       ├─ 6-10 attempts → Lock 15 minutes
       └─ 11+ attempts → Permanent lock + force logout 24h
```

## Auto-Reset Mechanism

Jika `temporary_lock_until` sudah lewat (≤ now()):

- `temporary_lock_until` di-set ke `NULL`
- `failed_login_counter` di-reset ke `0`
- User bisa mencoba login lagi (fresh start)

## Audit Trail

Setiap lockout event dicatat di `audit_logs`:

| Event                          | Description                       | Tags                                 |
| ------------------------------ | --------------------------------- | ------------------------------------ |
| `ACCOUNT_TEMPORARY_LOCK_5MIN`  | First 5 failed attempts           | security,temporary_lock              |
| `ACCOUNT_TEMPORARY_LOCK_15MIN` | Second 5 failed attempts          | security,temporary_lock              |
| `ACCOUNT_PERMANENTLY_LOCKED`   | 11+ failed attempts               | security,account_locked,force_logout |
| `LOGIN_ATTEMPT_TEMPORARY_LOCK` | Login attempt saat temporary lock | security,authentication              |
| `LOGIN_ATTEMPT_LOCKED_ACCOUNT` | Login attempt saat permanent lock | security,authentication              |

## Security Features

1. **Progressive Escalation**: Durasi lockout meningkat secara bertahap
2. **Persistent Counter**: `failed_login_counter` tidak di-reset sampai login berhasil atau lock expired
3. **Session Revocation**: Saat permanent lock, semua session di-revoke
4. **JWT Middleware Check**: Token valid tapi user locked = REJECT
5. **Audit Logging**: Semua event di-track untuk forensic analysis
6. **Force Logout**: User tidak bisa bypass dengan token lama

## Migration Steps

1. Run SQL migration:

```bash
mysql -u root -p lania_sso < prisma/migration-add-temporary-lock.sql
```

2. Generate Prisma client:

```bash
npx prisma generate
```

3. Restart application:

```bash
npm run start:dev
```

## Testing Scenarios

### Scenario 1: First 5 Attempts

```bash
# Try 3 wrong passwords
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"usernameOrEmail":"test@example.com","password":"wrong"}'

# Response: "Invalid credentials. Account temporarily locked for 5 minutes. (Attempt 3/5)"
# Wait 5 minutes or check temporary_lock_until
```

### Scenario 2: Second 5 Attempts

```bash
# After first 5 attempts, lock expires, try 6 more times
# Response: "Account temporarily locked for 15 minutes..."
```

### Scenario 3: Permanent Lock

```bash
# After 11+ attempts
# Response: "Account locked permanently..."
# Check: is_locked = true, force_logout_at = +24h
```

## Admin Unlock

Untuk unlock account yang permanent locked:

```sql
UPDATE users
SET
  is_locked = false,
  failed_login_counter = 0,
  temporary_lock_until = NULL,
  force_logout_at = NULL,
  locked_at = NULL
WHERE id = 'user-uuid';
```

## Notes

- Temporary lock bersifat **automatic reset** setelah durasi habis
- Permanent lock **butuh manual intervention** dari admin/support
- Failed login counter **hanya di-reset** saat login berhasil atau lock expired
- Force logout berlaku untuk **semua devices**
