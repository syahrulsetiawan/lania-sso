# Row Level Security (RLS) Implementation

This document explains the Row Level Security implementation in the Laniakea SSO application.

## 🎯 Overview

Row Level Security (RLS) ensures that users can only access data belonging to their current tenant. This implementation provides automatic tenant data isolation at the database level.

## 📁 Files Structure

```
src/
├── common/
│   ├── services/
│   │   └── tenant-rls.service.ts      # RLS context management
│   ├── middleware/
│   │   └── tenant-context.middleware.ts # Middleware for setting tenant context
│   ├── interceptors/
│   │   └── tenant-rls.interceptor.ts   # Interceptor for automatic RLS
│   ├── guards/
│   │   └── jwt-auth.guard.ts          # Updated with RLS integration
│   ├── tenant-rls.module.ts           # RLS module
│   └── index.ts                       # Exports
├── rls-test/
│   ├── rls-test.controller.ts         # Test endpoints for RLS verification
│   └── rls-test.module.ts             # Test module
├── prisma/
│   └── prisma.service.ts              # Updated with RLS utilities
└── app.module.ts                      # Updated with RLS module
```

## 🔧 How It Works

### 1. Database Level (PostgreSQL)

RLS policies are enabled on tenant-aware tables:

- `tenant_configs`
- `tenant_connections`
- `tenant_licenses`
- `tenant_has_service`
- `audit_logs`

Each policy filters data based on `app.current_tenant_id` session variable.

### 2. Application Level

#### JWT Authentication Guard

- Extracts user's `lastTenantId` after token verification
- Automatically sets RLS context using `TenantRlsService`
- Ensures all subsequent queries are filtered by tenant

#### Tenant RLS Service

- `setTenantContext(tenantId)` - Sets RLS context for current session
- `clearTenantContext()` - Clears RLS context
- `executeWithTenantContext()` - Runs operation with specific tenant context
- `verifyRlsIsolation()` - Tests RLS functionality

#### Middleware & Interceptors

- `TenantContextMiddleware` - Sets context early in request pipeline
- `TenantRlsInterceptor` - Automatic context management per request

## 🚀 Usage Examples

### Automatic (Recommended)

RLS is automatically applied when users are authenticated:

```typescript
// After login, all queries are automatically filtered by user's tenant
const configs = await prisma.tenantConfig.findMany();
// ↑ Only returns configs for user's current tenant
```

### Manual Context Management

For admin operations or cross-tenant queries:

```typescript
// Execute with specific tenant context
await tenantRlsService.executeWithTenantContext('tenant-id', async () => {
  const configs = await prisma.tenantConfig.findMany();
  return configs;
});

// Execute without tenant context (admin operation)
await tenantRlsService.executeWithoutTenantContext(async () => {
  const allTenants = await prisma.tenant.findMany();
  return allTenants;
});
```

### Prisma Service Utilities

```typescript
// Set tenant context manually
await prisma.setTenantContext('tenant-id');

// Execute with temporary context
await prisma.withTenantContext('tenant-id', async () => {
  // Your queries here
});

// Clear context
await prisma.clearTenantContext();
```

## 🧪 Testing RLS

Use the test endpoints to verify RLS functionality:

### 1. Basic RLS Test

```http
GET /rls/test
Authorization: Bearer <your-jwt-token>
```

Shows:

- Current RLS context
- Sample tenant-filtered data
- Verification that context matches user's tenant

### 2. RLS Isolation Verification

```http
GET /rls/verify
Authorization: Bearer <your-jwt-token>
```

Tests:

- Data isolation between tenants
- Returns PASS/FAIL status

### 3. Cross-Tenant Access Test

```http
GET /rls/cross-tenant-test
Authorization: Bearer <your-jwt-token>
```

Tests:

- Access to different tenant contexts
- Demonstrates proper isolation

## 🔒 Security Considerations

### 1. Automatic Context Setting

- RLS context is automatically set during authentication
- No manual intervention required for standard operations
- Context persists for the duration of the database session

### 2. Error Handling

- RLS failures don't break authentication
- Graceful fallback if RLS context fails to set
- Detailed logging for debugging

### 3. Admin Operations

- Use `executeWithoutTenantContext()` for admin queries
- Superuser database role can bypass RLS
- Clear audit trail for admin operations

## 📋 Database Tables Affected

### With RLS Policies:

- ✅ `tenant_configs` - Tenant configurations
- ✅ `tenant_connections` - Database connections
- ✅ `tenant_licenses` - License configurations
- ✅ `tenant_has_service` - Tenant-service mappings

### Without RLS (Global):

- ❌ `users` - Global user accounts
- ❌ `tenants` - Tenant definitions
- ❌ `core_services` - Service definitions
- ❌ `core_licenses` - License types
- ❌ `sessions` - User sessions
- ❌ `refresh_tokens` - JWT tokens
- ❌ `audit_logs` - Audit trail (consumed by system, not users)

## 🐛 Troubleshooting

### Check RLS Context

```typescript
const context = await tenantRlsService.getCurrentTenantContext();
console.log('Current tenant context:', context);
```

### Verify RLS Policies

```sql
-- Check if RLS is enabled on a table
SELECT schemaname, tablename, rowsecurity
FROM pg_tables
WHERE rowsecurity = true;

-- View RLS policies
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual
FROM pg_policies;
```

### Debug Queries

```typescript
// Enable query logging in development
// Check prisma.service.ts for query logging setup
```

## 🔄 Migration Notes

When adding new tenant-aware tables:

1. **Add RLS Policy in SQL:**

```sql
ALTER TABLE your_new_table ENABLE ROW LEVEL SECURITY;

CREATE POLICY your_new_table_tenant_isolation ON your_new_table
    FOR ALL USING (tenant_id = get_current_tenant_id());
```

2. **Update Documentation:**

- Add table to "Database Tables Affected" section
- Update any relevant test cases

## 🎯 Best Practices

1. **Always use authenticated requests** - RLS context depends on user authentication
2. **Test tenant isolation** - Use `/rls/verify` endpoint regularly
3. **Monitor RLS logs** - Check application logs for RLS context issues
4. **Use transactions carefully** - RLS context persists within transactions
5. **Admin operations** - Use dedicated service methods for cross-tenant operations

## 🔗 Related Documentation

- [Database Schema](../lania_sso_postgres.sql) - Full database schema with RLS policies
- [Authentication](../auth/README.md) - JWT authentication flow
- [Tenant Management](../tenants/README.md) - Tenant configuration management
