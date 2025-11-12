# Session-Based JWT - Quick Reference

## TL;DR

JWT sekarang hanya berisi `session_id`, bukan data user. Ini untuk security & device management.

---

## What Changed?

### JWT Payload

```diff
- { "sub": "user-id", "email": "user@example.com", "username": "johndoe" }
+ { "session_id": "uuid-here", "type": "access" }
```

### Request User Object

```diff
- request.user.sub          // ❌ Tidak ada lagi
- request.user.email        // ❌ Tidak ada lagi
- request.user.username     // ❌ Tidak ada lagi

+ request.user.id           // ✅ Pakai ini
+ request.user.email        // ✅ Dari database
+ request.user.username     // ✅ Dari database
+ request.user.sessionId    // ✅ NEW - untuk tracking
```

---

## For Backend Developers

### Accessing User in Controllers

```typescript
@Get('me')
@UseGuards(JwtAuthGuard)
async getMe(@Req() request: any) {
  // ✅ Correct way
  const userId = request.user.id;
  const email = request.user.email;
  const sessionId = request.user.sessionId;

  // ❌ Wrong way (tidak ada lagi)
  const userId = request.user.sub;
}
```

### Available Fields in request.user

```typescript
{
  id: string; // User ID
  name: string; // Full name
  username: string; // Username
  email: string; // Email
  phone: string | null; // Phone number
  profilePhotoPath: string | null;
  lastTenantId: string | null;
  lastServiceKey: string | null;
  sessionId: string; // NEW - Session ID
}
```

---

## For Frontend Developers

### Login (No Changes)

```typescript
const { data } = await axios.post('/api/v1/auth/login', {
  usernameOrEmail: 'johndoe',
  password: 'SecurePass123!',
});
localStorage.setItem('accessToken', data.accessToken);
```

### Error Handling (NEW)

```typescript
axios.interceptors.response.use(
  (response) => response,
  async (error) => {
    if (error.response?.status === 401) {
      const reason = error.response?.data?.error?.reason;

      // ✅ NEW: Handle session revoked
      if (reason === 'session_revoked') {
        alert('Your session was revoked from another device');
        localStorage.clear();
        window.location.href = '/login';
        return;
      }
    }
  },
);
```

### Switch Tenant (CHANGED)

```diff
// ❌ Before - Update token
const { data } = await axios.post('/switch-tenant', { tenantId });
- localStorage.setItem('accessToken', data.accessToken); // No more token!

// ✅ After - Just re-fetch user
const { data } = await axios.post('/switch-tenant', { tenantId });
+ const user = await axios.get('/me'); // Get updated lastTenantId
```

### Device Management (NEW)

```typescript
// List active devices
const { data } = await axios.get('/api/v1/auth/sessions');
data.sessions.forEach((session) => {
  console.log(`${session.deviceName} - ${session.lastActivity}`);
  console.log(`Current: ${session.isCurrent}`);
});

// Revoke session (logout device)
await axios.delete(`/api/v1/auth/sessions/${sessionId}`);
```

---

## New Endpoints

### GET /api/v1/auth/sessions

List all active sessions (logged-in devices).

```bash
curl -X GET http://localhost:3000/api/v1/auth/sessions \
  -H "Authorization: Bearer <token>"
```

**Response:**

```json
{
  "message": "Active sessions retrieved successfully",
  "sessions": [
    {
      "id": "uuid-1",
      "deviceName": "Chrome on Windows",
      "ipAddress": "192.168.1.100",
      "lastActivity": "2025-11-12T14:30:00Z",
      "isCurrent": true
    }
  ]
}
```

### DELETE /api/v1/auth/sessions/:id

Revoke specific session (force logout on that device).

```bash
curl -X DELETE http://localhost:3000/api/v1/auth/sessions/uuid-1 \
  -H "Authorization: Bearer <token>"
```

**Response:**

```json
{
  "message": "Session revoked successfully"
}
```

---

## New Error Codes

| Status | Reason                    | Meaning                                  | Action                    |
| ------ | ------------------------- | ---------------------------------------- | ------------------------- |
| 401    | `session_not_found`       | Session ID tidak ada di database         | Force logout              |
| 401    | `session_revoked`         | Session sudah di-revoke dari device lain | Force logout + notifikasi |
| 400    | `session_already_revoked` | Trying to revoke already-revoked session | Show error                |

---

## Common Scenarios

### 1. User Login from New Device

```
User logs in → Session created → JWT contains session_id
```

### 2. User Makes API Request

```
Frontend sends JWT → Guard extracts session_id →
Query sessions table → Check revoked_at →
Attach user data → Continue to controller
```

### 3. User Revokes Device

```
User clicks "Logout iPhone" → DELETE /sessions/:id →
Session revoked (revoked_at = NOW()) →
Next request from iPhone → 401 session_revoked
```

### 4. User Changes Password

```
Password changed → All sessions revoked →
User must re-login on all devices
```

### 5. Admin Locks User

```
Admin locks user → All sessions revoked →
User gets 401 account_locked on next request
```

---

## Testing

### Test Session-Based JWT

```bash
# 1. Login
POST /auth/login
→ Get accessToken

# 2. Decode JWT (jwt.io)
→ Should only have { session_id, type, iat, exp }

# 3. Get user
GET /auth/me (with token)
→ Should return full user data

# 4. Get sessions
GET /auth/sessions (with token)
→ Should return list of sessions

# 5. Revoke session
DELETE /auth/sessions/:id (with token)
→ Should revoke session

# 6. Use revoked token
GET /auth/me (with revoked token)
→ Should return 401 session_revoked
```

---

## FAQ

**Q: Do I need to change my frontend code?**  
A: Minimal changes:

- Handle `session_revoked` error
- Remove token update after switch tenant
- Optional: Add device management UI

**Q: Will existing tokens work?**  
A: No. All users must re-login after deployment.

**Q: Is there a performance impact?**  
A: No. Same 1 database query per request (just different structure).

**Q: Can I still use refresh tokens?**  
A: Yes, refresh token flow unchanged.

**Q: How do I test locally?**  
A: `npm run start:dev` → Login → Check JWT payload → Test endpoints

---

## Quick Links

- **Full Documentation**: `SESSION-BASED-JWT.md`
- **Migration Guide**: `MIGRATION-SESSION-JWT.md`
- **API Docs**: `AUTH-API.md`
- **Implementation Summary**: `IMPLEMENTATION-SESSION-JWT.md`

---

## Need Help?

1. Check documentation files above
2. Test in development: `npm run start:dev`
3. Review code changes in Git
4. Ask team for clarification

---

**Last Updated**: November 12, 2025  
**Status**: ✅ Ready for Testing

© 2025 Laniakea SSO
