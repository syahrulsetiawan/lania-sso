# Migration: Session-Based JWT Implementation

## Overview

Migration dari traditional JWT (user data di payload) ke session-based JWT (hanya session_id di payload) untuk keamanan dan device management.

## Changes Summary

### Modified Files

1. **src/auth/auth.service.ts**
   - `generateAccessToken()`: Signature berubah dari `(userId, email, username)` ke `(sessionId)`
   - `login()`: Generate JWT dengan session_id saja
   - `refresh()`: Generate JWT dengan session_id saja
   - `switchTenant()`: Tidak lagi generate token baru (pakai session yang sama)
   - **NEW**: `getUserSessions()` - List active sessions
   - **NEW**: `revokeSession()` - Revoke specific session

2. **src/common/guards/jwt-auth.guard.ts**
   - Extract `session_id` dari JWT payload
   - Query `sessions` table untuk get user data
   - Check `session.revoked_at` untuk instant revocation
   - Attach full user data dari database (bukan dari JWT)

3. **src/auth/auth.controller.ts**
   - **NEW**: `GET /auth/sessions` - Get active devices
   - **NEW**: `DELETE /auth/sessions/:id` - Revoke session

4. **src/auth/dto/switch-tenant.dto.ts**
   - Remove `accessToken`, `expiresIn`, `tokenType` dari response
   - Hanya return `message` dan `tenant` info

### New Files

1. **src/auth/dto/device-management.dto.ts** - DTOs for session management
2. **SESSION-BASED-JWT.md** - Complete documentation
3. **MIGRATION-SESSION-JWT.md** - This file

## Database Schema

No database changes required! `sessions` table sudah ada dengan field `revoked_at`.

## Breaking Changes

### 1. JWT Payload Structure

**Before:**

```json
{
  "sub": "user-id",
  "email": "user@example.com",
  "username": "johndoe",
  "type": "access",
  "iat": 1699876543,
  "exp": 1699880143
}
```

**After:**

```json
{
  "session_id": "550e8400-e29b-41d4-a716-446655440001",
  "type": "access",
  "iat": 1699876543,
  "exp": 1699880143
}
```

### 2. Request User Object

**Before (in controllers):**

```typescript
@Get('me')
async getMe(@Req() request: any) {
  const userId = request.user.sub;      // ❌ Won't work
  const email = request.user.email;     // ❌ Won't work
  const username = request.user.username; // ❌ Won't work
}
```

**After (in controllers):**

```typescript
@Get('me')
async getMe(@Req() request: any) {
  const userId = request.user.id;          // ✅ From database
  const email = request.user.email;        // ✅ From database
  const username = request.user.username;  // ✅ From database
  const sessionId = request.user.sessionId; // ✅ NEW
}
```

### 3. Switch Tenant Response

**Before:**

```json
{
  "message": "Successfully switched to tenant",
  "accessToken": "eyJhbGc...",  // ❌ Removed
  "expiresIn": 3600,             // ❌ Removed
  "tokenType": "Bearer",         // ❌ Removed
  "tenant": { ... }
}
```

**After:**

```json
{
  "message": "Successfully switched to tenant",
  "tenant": { ... }
}
```

**Reason**: Tidak perlu generate token baru karena session tetap sama. Frontend hanya perlu re-fetch `/me` untuk get updated `lastTenantId`.

## Migration Steps

### 1. Update Existing Code

Jika ada controller code yang akses `request.user.sub`:

```typescript
// ❌ Before
const userId = request.user.sub || request.user.userId;

// ✅ After
const userId = request.user.id;
```

### 2. Update Frontend Integration

#### Login Flow (No Changes)

```typescript
// Sama seperti sebelumnya
const { data } = await axios.post('/api/v1/auth/login', {
  usernameOrEmail: 'johndoe',
  password: 'SecurePass123!',
});

// Store tokens
localStorage.setItem('accessToken', data.accessToken);
localStorage.setItem('refreshToken', data.refreshToken);
```

#### Get Current User (No Changes)

```typescript
// Sama seperti sebelumnya
const { data } = await axios.get('/api/v1/auth/me', {
  headers: { Authorization: `Bearer ${accessToken}` },
});
```

#### Switch Tenant (Updated Response)

```typescript
// ❌ Before
const { data } = await axios.post('/api/v1/auth/switch-tenant', {
  tenantId: 'tenant-uuid',
});
// data.accessToken - update stored token
localStorage.setItem('accessToken', data.accessToken);

// ✅ After
const { data } = await axios.post('/api/v1/auth/switch-tenant', {
  tenantId: 'tenant-uuid',
});
// No new token! Just re-fetch user to get updated lastTenantId
const user = await axios.get('/api/v1/auth/me');
```

#### Error Handling (New)

```typescript
axios.interceptors.response.use(
  (response) => response,
  async (error) => {
    if (error.response?.status === 401) {
      const reason = error.response?.data?.error?.reason;

      // ✅ NEW: Handle session_revoked
      if (reason === 'session_revoked') {
        // Session was revoked from another device
        localStorage.clear();
        window.location.href = '/login?reason=session_revoked';
        return;
      }

      // Existing refresh logic...
    }
  },
);
```

### 3. Device Management (New Feature)

```typescript
// Get active sessions
const { data } = await axios.get('/api/v1/auth/sessions');
console.log(data.sessions);
// [
//   { id: '...', deviceName: 'Chrome on Windows', isCurrent: true },
//   { id: '...', deviceName: 'Safari on iPhone', isCurrent: false }
// ]

// Revoke session
await axios.delete(`/api/v1/auth/sessions/${sessionId}`);
```

## Testing Migration

### 1. Test Login & JWT Payload

```bash
# Login
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "usernameOrEmail": "johndoe",
    "password": "SecurePass123!"
  }'

# Decode JWT (use jwt.io)
# Payload should only have: { session_id, type, iat, exp }
```

### 2. Test Session Revocation

```bash
# Get sessions
curl -X GET http://localhost:3000/api/v1/auth/sessions \
  -H "Authorization: Bearer <token>"

# Revoke session
curl -X DELETE http://localhost:3000/api/v1/auth/sessions/<session-id> \
  -H "Authorization: Bearer <token>"

# Try to use revoked session's token
curl -X GET http://localhost:3000/api/v1/auth/me \
  -H "Authorization: Bearer <revoked-token>"
# Expected: 401 Unauthorized { reason: "session_revoked" }
```

### 3. Test Switch Tenant

```bash
# Switch tenant
curl -X POST http://localhost:3000/api/v1/auth/switch-tenant \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{ "tenantId": "tenant-uuid" }'

# Response should NOT include accessToken
# { "message": "...", "tenant": {...} }

# Get updated user
curl -X GET http://localhost:3000/api/v1/auth/me \
  -H "Authorization: Bearer <same-token>"
# user.lastTenantId should be updated
```

## Rollback Plan

Jika ada issue, rollback dengan:

```bash
git revert <commit-hash>
```

File yang berubah:

- `src/auth/auth.service.ts`
- `src/common/guards/jwt-auth.guard.ts`
- `src/auth/auth.controller.ts`
- `src/auth/dto/switch-tenant.dto.ts`
- `src/auth/dto/device-management.dto.ts` (hapus file)
- `src/auth/dto/index.ts`

## Performance Impact

### Database Queries

**Before**: 1 query per request (user lookup for validation)
**After**: 1 query per request (session lookup dengan join user)

No additional performance overhead - hanya struktur query yang berbeda.

### Optimization

Jika traffic tinggi, implement Redis caching:

```typescript
// Cache session data
const cacheKey = `session:${sessionId}`;
let session = await redis.get(cacheKey);

if (!session) {
  session = await prisma.session.findUnique({ ... });
  await redis.setex(cacheKey, 3600, JSON.stringify(session));
}
```

## Security Improvements

1. ✅ **No User Data in JWT**: Tidak ada data sensitive exposed di client
2. ✅ **Instant Revocation**: Revoke session langsung efektif
3. ✅ **Device Tracking**: Track semua device yang login
4. ✅ **Better Audit**: Complete session history

## New Error Codes

| Error Code | Reason                    | Action                                                   |
| ---------- | ------------------------- | -------------------------------------------------------- |
| 401        | `session_not_found`       | Session ID tidak ada di database - force logout          |
| 401        | `session_revoked`         | Session sudah di-revoke - force logout dengan notifikasi |
| 400        | `session_already_revoked` | Attempt to revoke already-revoked session                |

## FAQ

### Q: Apakah existing tokens masih bisa dipakai?

**A**: Tidak. Existing tokens (sebelum migration) memiliki payload berbeda (sub, email, username). Setelah migration, semua user harus login ulang untuk dapat token baru dengan format session-based.

**Solusi**: Force logout semua user saat deployment:

```sql
-- Revoke all sessions
UPDATE sessions SET revoked_at = NOW();

-- Revoke all refresh tokens
UPDATE refresh_tokens SET revoked = 1, revoked_at = NOW();
```

### Q: Apakah perlu database migration?

**A**: Tidak. Table `sessions` sudah ada dengan field `revoked_at`. Tidak ada schema changes.

### Q: Bagaimana dengan refresh token?

**A**: Refresh token flow tetap sama. Hanya access token yang berubah payload-nya. Refresh token tetap di database dengan SHA-256 hash.

### Q: Performance overhead berapa?

**A**: Minimal. Setiap request tetap 1 query (sebelumnya user lookup, sekarang session lookup dengan join). Jika perlu, implement Redis caching.

## Deployment Checklist

- [ ] Review semua perubahan code
- [ ] Test di development environment
- [ ] Update frontend error handling untuk `session_revoked`
- [ ] Update frontend switch tenant (remove token update logic)
- [ ] Test device management UI
- [ ] Deploy backend
- [ ] Force logout semua user (revoke all sessions)
- [ ] Announce maintenance window (5 menit)
- [ ] Monitor error logs
- [ ] Verify session revocation works

## Support

Jika ada issue setelah migration:

1. Check error logs untuk pattern errors
2. Verify JWT payload structure (use jwt.io)
3. Check database - sessions table `revoked_at` field
4. Test dengan fresh login (new session)

---

**Migration Date**: November 12, 2025  
**Status**: Ready for deployment  
**Impact**: All users must re-login after deployment

© 2025 Laniakea SSO - Session-Based JWT Migration
