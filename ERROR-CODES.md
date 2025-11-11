# Error Codes & Reason Reference

Dokumentasi lengkap untuk semua `reason` codes yang digunakan di response error API. Gunakan untuk dynamic language/translation di frontend.

## Error Response Format

```json
{
  "statusCode": 401,
  "message": "Your account has been locked. Please contact support.",
  "reason": "account_locked",
  "timestamp": "2025-11-11T14:30:00.000Z"
}
```

---

## 🔐 Authentication Errors (Login)

### `invalid_credentials`

- **HTTP Status**: 401 Unauthorized
- **Trigger**: Username/email atau password salah
- **Message**: "Invalid credentials"
- **Frontend Action**: Tampilkan error di form login

### `account_locked`

- **HTTP Status**: 401 Unauthorized
- **Trigger**: User di-lock permanen (`is_locked = true`)
- **Message**: "Your account has been locked. Please contact support."
- **Frontend Action**: Tampilkan pesan hubungi support, disable login button

### `temporary_locked`

- **HTTP Status**: 401 Unauthorized
- **Trigger**: User sedang temporary lock (dari JWT guard check)
- **Message**: "Account temporarily locked. Try again in X minute(s)."
- **Extra Data**:
  - `lockedUntil`: ISO timestamp
  - `minutesRemaining`: number
- **Frontend Action**: Tampilkan countdown timer, disable login button

### `temporary_locked_5min`

- **HTTP Status**: 401 Unauthorized
- **Trigger**: 1-5 failed login attempts
- **Message**: "Invalid credentials. Account temporarily locked for 5 minutes. (Attempt X/5)"
- **Extra Data**:
  - `lockedUntil`: ISO timestamp
  - `failedAttempts`: number
  - `minutesRemaining`: 5
- **Frontend Action**: Tampilkan pesan lock 5 menit + counter attempts

### `temporary_locked_15min`

- **HTTP Status**: 401 Unauthorized
- **Trigger**: 6-10 failed login attempts
- **Message**: "Account temporarily locked for 15 minutes due to multiple failed login attempts."
- **Extra Data**:
  - `lockedUntil`: ISO timestamp
  - `failedAttempts`: number
  - `minutesRemaining`: 15
- **Frontend Action**: Tampilkan pesan lock 15 menit

### `account_permanently_locked`

- **HTTP Status**: 401 Unauthorized
- **Trigger**: 11+ failed login attempts
- **Message**: "Account locked permanently due to too many failed login attempts. Please contact support."
- **Extra Data**:
  - `failedAttempts`: number
- **Frontend Action**: Tampilkan pesan permanen lock, hubungi support

### `no_active_tenant`

- **HTTP Status**: 401 Unauthorized
- **Trigger**: User tidak punya tenant relationship yang aktif
- **Message**: "Your account is not associated with any active tenant."
- **Frontend Action**: Tampilkan pesan hubungi admin untuk assign tenant

### `tenant_inactive_or_revoked`

- **HTTP Status**: 401 Unauthorized
- **Trigger**: Semua tenant user inactive atau revoked
- **Message**: "All your tenants are inactive or revoked. Please contact support."
- **Frontend Action**: Tampilkan pesan hubungi support untuk aktivasi tenant

### `account_suspended`

- **HTTP Status**: 401 Unauthorized
- **Trigger**: `force_logout_at` masih aktif
- **Message**: "Your account is temporarily suspended."
- **Frontend Action**: Tampilkan pesan akun suspended, hubungi support

---

## 🔄 Refresh Token Errors

### `invalid_refresh_token`

- **HTTP Status**: 401 Unauthorized
- **Trigger**: Refresh token tidak ditemukan di database
- **Message**: "Invalid refresh token"
- **Frontend Action**: Clear session, redirect ke login

### `refresh_token_revoked`

- **HTTP Status**: 401 Unauthorized
- **Trigger**: Refresh token sudah di-revoke
- **Message**: "Refresh token has been revoked"
- **Frontend Action**: Clear session, redirect ke login

### `refresh_token_expired`

- **HTTP Status**: 401 Unauthorized
- **Trigger**: Refresh token sudah expired (> 7 hari)
- **Message**: "Refresh token has expired"
- **Frontend Action**: Clear session, redirect ke login dengan pesan "Session expired"

### `session_terminated`

- **HTTP Status**: 401 Unauthorized
- **Trigger**: Session sudah di-revoke (logout dari device lain)
- **Message**: "Session has been terminated"
- **Frontend Action**: Clear session, redirect ke login dengan pesan "Logged out from another device"

---

## 🔑 Password Reset Errors

### `password_mismatch`

- **HTTP Status**: 400 Bad Request
- **Trigger**: Password dan password confirmation tidak sama
- **Message**: "Passwords do not match"
- **Frontend Action**: Highlight password confirmation field

### `invalid_reset_token`

- **HTTP Status**: 400 Bad Request
- **Trigger**: Reset token tidak valid atau tidak ditemukan
- **Message**: "Invalid or expired reset token"
- **Frontend Action**: Tampilkan pesan "Link expired, request new reset link"

### `reset_token_expired`

- **HTTP Status**: 400 Bad Request
- **Trigger**: Reset token sudah expired (> 60 menit)
- **Message**: "Reset token has expired"
- **Frontend Action**: Redirect ke forgot password page

### `user_not_found`

- **HTTP Status**: 400 Bad Request (reset password) / 401 Unauthorized (getMe)
- **Trigger**: User tidak ditemukan atau sudah deleted
- **Message**: "User not found"
- **Frontend Action**: Tampilkan error atau redirect ke login

---

## 🚪 Logout Errors

### `no_authorization_header`

- **HTTP Status**: 401 Unauthorized
- **Trigger**: Request logout tanpa Authorization header
- **Message**: "No authorization header"
- **Frontend Action**: Clear local session, redirect ke login

---

## 🛡️ JWT Guard Errors (Middleware)

Dari `jwt-auth.guard.ts`:

### `no_token`

- **HTTP Status**: 401 Unauthorized
- **Trigger**: Request tanpa Bearer token
- **Message**: "Access token not provided"
- **Frontend Action**: Redirect ke login

### `invalid_token`

- **HTTP Status**: 401 Unauthorized
- **Trigger**: Token tidak valid atau malformed
- **Message**: "Invalid or expired token"
- **Frontend Action**: Clear session, redirect ke login

### `user_not_found` (dari guard)

- **HTTP Status**: 401 Unauthorized
- **Trigger**: User dari token sudah tidak ada atau deleted
- **Message**: "User not found or deleted"
- **Frontend Action**: Clear session, redirect ke login

### `account_locked` (dari guard)

- **HTTP Status**: 401 Unauthorized
- **Trigger**: User locked saat mengakses protected route
- **Message**: "Your account has been locked. Please contact support."
- **Frontend Action**: Show modal, disable actions, logout

### `temporary_lock` (dari guard)

- **HTTP Status**: 401 Unauthorized
- **Trigger**: User temporary locked saat mengakses protected route
- **Message**: "Account temporarily locked. Try again in X minute(s)."
- **Extra Data**:
  - `lockedUntil`: ISO timestamp
- **Frontend Action**: Show countdown modal, logout after

### `force_logout` (dari guard)

- **HTTP Status**: 401 Unauthorized
- **Trigger**: User force logout saat mengakses protected route
- **Message**: "Your account is temporarily suspended."
- **Frontend Action**: Force logout, show suspension message

---

## 📊 Summary Table

| Reason Code                  | Status  | Trigger           | Action          |
| ---------------------------- | ------- | ----------------- | --------------- |
| `invalid_credentials`        | 401     | Wrong password    | Show error      |
| `account_locked`             | 401     | Permanent lock    | Contact support |
| `temporary_locked`           | 401     | Temp lock (check) | Show timer      |
| `temporary_locked_5min`      | 401     | 1-5 fails         | Lock 5 min      |
| `temporary_locked_15min`     | 401     | 6-10 fails        | Lock 15 min     |
| `account_permanently_locked` | 401     | 11+ fails         | Contact support |
| `no_active_tenant`           | 401     | No tenant         | Contact admin   |
| `tenant_inactive_or_revoked` | 401     | Tenant inactive   | Contact support |
| `account_suspended`          | 401     | Force logout      | Contact support |
| `invalid_refresh_token`      | 401     | Bad token         | Re-login        |
| `refresh_token_revoked`      | 401     | Revoked           | Re-login        |
| `refresh_token_expired`      | 401     | Expired           | Re-login        |
| `session_terminated`         | 401     | Session revoked   | Re-login        |
| `password_mismatch`          | 400     | Passwords differ  | Fix input       |
| `invalid_reset_token`        | 400     | Bad reset token   | Request new     |
| `reset_token_expired`        | 400     | Token expired     | Request new     |
| `user_not_found`             | 400/401 | User deleted      | Re-login        |
| `no_authorization_header`    | 401     | No auth header    | Re-login        |
| `no_token`                   | 401     | Missing token     | Re-login        |
| `invalid_token`              | 401     | Bad JWT           | Re-login        |
| `temporary_lock` (guard)     | 401     | Locked check      | Show timer      |
| `force_logout` (guard)       | 401     | Suspended check   | Force logout    |

---

## 💡 Frontend Implementation Example

### JavaScript/TypeScript

```typescript
// Error handler
const handleApiError = (error: any) => {
  const reason = error.response?.data?.reason;
  const message = error.response?.data?.message;

  switch (reason) {
    case 'invalid_credentials':
      showNotification(t('error.invalid_credentials'), 'error');
      break;

    case 'account_locked':
      showModal({
        title: t('error.account_locked_title'),
        message: t('error.account_locked_message'),
        actions: [{ label: t('contact_support'), onClick: contactSupport }],
      });
      break;

    case 'temporary_locked_5min':
    case 'temporary_locked_15min':
      const minutes = error.response?.data?.minutesRemaining;
      startCountdown(minutes, () => {
        enableLoginButton();
      });
      showNotification(t('error.temporary_locked', { minutes }), 'warning');
      break;

    case 'account_permanently_locked':
      showModal({
        title: t('error.permanently_locked_title'),
        message: t('error.permanently_locked_message'),
        closable: false,
        actions: [{ label: t('contact_support'), onClick: contactSupport }],
      });
      disableLoginButton();
      break;

    case 'refresh_token_expired':
    case 'session_terminated':
      clearSession();
      redirectToLogin(t('error.session_expired'));
      break;

    default:
      showNotification(message || t('error.general'), 'error');
  }
};
```

### Translation File (i18n)

```json
{
  "error": {
    "invalid_credentials": "Email atau password salah",
    "account_locked_title": "Akun Terkunci",
    "account_locked_message": "Akun Anda telah dikunci. Silakan hubungi support.",
    "temporary_locked": "Akun dikunci sementara. Coba lagi dalam {{minutes}} menit.",
    "permanently_locked_title": "Akun Terkunci Permanen",
    "permanently_locked_message": "Terlalu banyak percobaan login gagal. Hubungi support untuk unlock.",
    "session_expired": "Sesi Anda telah berakhir. Silakan login kembali.",
    "general": "Terjadi kesalahan. Silakan coba lagi."
  },
  "contact_support": "Hubungi Support"
}
```

---

## 🎨 UI/UX Recommendations

### Temporary Lock (5/15 min)

```html
<div class="alert alert-warning">
  <i class="icon-clock"></i>
  <div>
    <strong>Akun Dikunci Sementara</strong>
    <p>
      Terlalu banyak percobaan gagal. Coba lagi dalam
      <span id="countdown">5:00</span>
    </p>
  </div>
</div>
```

### Permanent Lock

```html
<div class="modal">
  <i class="icon-lock-closed"></i>
  <h2>Akun Dikunci</h2>
  <p>Akun Anda telah dikunci karena terlalu banyak percobaan login gagal.</p>
  <button onclick="contactSupport()">Hubungi Support</button>
</div>
```

### Failed Attempts Counter

```html
<div class="alert alert-danger">
  <p>Password salah. Percobaan ke-{{attempts}}/5</p>
  <small>Akun akan dikunci setelah 5 percobaan gagal</small>
</div>
```

---

## 🔍 Testing Error Codes

```bash
# Test invalid credentials
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{"usernameOrEmail":"test","password":"wrong"}'
# Expected: {"reason": "temporary_locked_5min"}

# Test locked account
# (After 11+ failed attempts)
# Expected: {"reason": "account_permanently_locked"}

# Test expired refresh token
curl -X POST http://localhost:3000/api/v1/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{"refreshToken":"expired-token"}'
# Expected: {"reason": "invalid_refresh_token"}
```

---

## 📝 Notes

- Semua `reason` codes menggunakan **snake_case** format
- `reason` field **always present** di semua error responses
- Extra data (seperti `minutesRemaining`, `lockedUntil`) bersifat **optional** tergantung error type
- Frontend **harus handle** semua reason codes untuk UX yang baik
- Gunakan `reason` untuk **i18n/translation**, bukan `message` (message untuk fallback)
