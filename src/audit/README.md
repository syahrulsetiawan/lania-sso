# Audit Trail Module

Comprehensive audit logging system for tracking all operations in the SSO system.

## 📋 Features

- ✅ Automatic audit logging via interceptor
- ✅ Manual audit logging via service
- ✅ Track user actions (create, update, delete)
- ✅ Track authentication events (login, logout)
- ✅ Store old and new values for data changes
- ✅ IP address and user agent tracking
- ✅ Flexible tagging system
- ✅ Query and filter audit logs
- ✅ Automatic cleanup of old logs

## 🗄️ Database Schema

```sql
CREATE TABLE `audit_logs` (
  `id` CHAR(36) PRIMARY KEY,
  `user_type` VARCHAR(255) -- User, Admin, System
  `user_id` VARCHAR(255) -- User identifier
  `event` VARCHAR(255) -- created, updated, deleted, login, etc.
  `auditable_table` VARCHAR(255) -- Table name
  `auditable_id` CHAR(36) -- Record ID
  `old_values` TEXT -- JSON of old values
  `new_values` TEXT -- JSON of new values
  `url` TEXT -- Request URL
  `payload` JSON -- Request payload
  `ip_address` VARCHAR(45) -- Client IP
  `user_agent` VARCHAR(255) -- Browser info
  `tags` VARCHAR(255) -- Comma-separated tags
  `created_at` TIMESTAMP
  `updated_at` TIMESTAMP
);
```

## 🚀 Usage

### 1. Import AuditModule

```typescript
import { Module } from '@nestjs/common';
import { AuditModule } from './audit';

@Module({
  imports: [AuditModule],
})
export class AppModule {}
```

### 2. Use AuditInterceptor (Automatic Logging)

```typescript
import { Controller, Post, UseInterceptors } from '@nestjs/common';
import { AuditInterceptor, AuditTable, AuditEvent } from './audit';

@Controller('users')
@UseInterceptors(AuditInterceptor)
@AuditTable('users') // Set table name for all routes
export class UserController {
  @Post()
  @AuditEvent('user_registered') // Custom event name
  async createUser(@Body() dto: CreateUserDto) {
    // Automatically logged with event: 'user_registered'
    return this.userService.create(dto);
  }

  @Put(':id')
  async updateUser(@Param('id') id: string, @Body() dto: UpdateUserDto) {
    // Automatically logged with event: 'updated' (inferred from PUT)
    return this.userService.update(id, dto);
  }
}
```

### 3. Use AuditService (Manual Logging)

```typescript
import { Injectable } from '@nestjs/common';
import { AuditService } from './audit';

@Injectable()
export class AuthService {
  constructor(private readonly auditService: AuditService) {}

  async login(email: string, password: string, request: FastifyRequest) {
    const user = await this.validateUser(email, password);

    if (!user) {
      // Log failed login
      await this.auditService.logFailedLogin(request, email);
      throw new UnauthorizedException('Invalid credentials');
    }

    // Log successful login
    await this.auditService.logUserLogin(request, user.id);

    return this.generateToken(user);
  }

  async logout(userId: string, request: FastifyRequest) {
    // Log logout
    await this.auditService.logUserLogout(request, userId);

    return this.revokeToken(userId);
  }
}
```

### 4. Manual Audit Logging with Custom Data

```typescript
import { Injectable } from '@nestjs/common';
import { AuditService } from './audit';

@Injectable()
export class UserService {
  constructor(private readonly auditService: AuditService) {}

  async updateUser(id: string, data: UpdateUserDto, request: FastifyRequest) {
    // Get old data
    const oldUser = await this.prisma.user.findUnique({ where: { id } });

    // Update user
    const newUser = await this.prisma.user.update({
      where: { id },
      data,
    });

    // Log the change with old and new values
    await this.auditService.logUserUpdated(
      request,
      id,
      oldUser,
      newUser,
      request['user'].id, // Updated by (from JWT)
    );

    return newUser;
  }
}
```

### 5. Generic Audit Logging

```typescript
await this.auditService.log({
  userType: 'Admin',
  userId: adminId,
  event: 'config_updated',
  auditableTable: 'system_configs',
  auditableId: configId,
  oldValues: { value: 'old_value' },
  newValues: { value: 'new_value' },
  url: '/api/v1/config/update',
  payload: requestBody,
  ipAddress: '192.168.1.1',
  userAgent: 'Mozilla/5.0...',
  tags: 'config,admin,security',
});
```

## 📊 Query Audit Logs

### Get Audit Logs with Filters

```typescript
const logs = await this.auditService.getAuditLogs({
  userId: 'user-123',
  auditableTable: 'users',
  event: 'updated',
  startDate: new Date('2024-01-01'),
  endDate: new Date('2024-12-31'),
  tags: 'security',
  skip: 0,
  take: 50,
});

console.log(logs);
// {
//   data: [...],
//   total: 150,
//   page: 1,
//   pageSize: 50,
//   totalPages: 3
// }
```

### Get Recent Logs

```typescript
const recentLogs = await this.auditService.getRecentLogs(100);
```

### Get Audit Statistics

```typescript
const stats = await this.auditService.getAuditStats(
  new Date('2024-01-01'),
  new Date('2024-12-31'),
);

console.log(stats);
// {
//   totalEvents: 1500,
//   eventsByType: [
//     { event: 'login', _count: 450 },
//     { event: 'updated', _count: 320 },
//     ...
//   ],
//   eventsByTable: [
//     { auditableTable: 'users', _count: 800 },
//     { auditableTable: 'sessions', _count: 500 },
//     ...
//   ]
// }
```

## 🧹 Cleanup Old Logs

### Manual Cleanup

```typescript
// Delete logs older than 90 days
const result = await this.auditService.cleanupOldLogs(90);
console.log(result);
// { deletedCount: 500, cutoffDate: Date }
```

### Using Stored Procedure

```sql
CALL sp_cleanup_old_audit_logs(90);
```

### Scheduled Cleanup (Cron Job)

```typescript
import { Injectable } from '@nestjs/common';
import { Cron, CronExpression } from '@nestjs/schedule';
import { AuditService } from './audit';

@Injectable()
export class AuditCleanupTask {
  constructor(private readonly auditService: AuditService) {}

  @Cron(CronExpression.EVERY_DAY_AT_MIDNIGHT)
  async cleanupOldLogs() {
    await this.auditService.cleanupOldLogs(90);
  }
}
```

## 📝 Event Types

### Authentication Events

- `login` - User logged in
- `logout` - User logged out
- `login_failed` - Failed login attempt
- `password_changed` - Password changed
- `password_reset` - Password reset

### CRUD Events

- `created` - Record created
- `updated` - Record updated
- `deleted` - Record deleted
- `accessed` - Record accessed (GET)

### Custom Events

You can define any custom event:

- `user_registered`
- `profile_completed`
- `email_verified`
- `2fa_enabled`
- `permission_granted`
- etc.

## 🏷️ Tagging System

Use comma-separated tags for better filtering:

```typescript
tags: 'user,security,critical';
tags: 'auth,login,failed';
tags: 'admin,config,updated';
```

Query by tags:

```typescript
const logs = await this.auditService.getAuditLogs({
  tags: 'security',
});
```

## 🔍 Audit Log Structure

Each audit log contains:

```typescript
{
  id: 'uuid',
  userType: 'Admin',
  userId: 'user-123',
  event: 'updated',
  auditableTable: 'users',
  auditableId: 'user-456',
  oldValues: '{"email":"old@example.com"}',
  newValues: '{"email":"new@example.com"}',
  url: '/api/v1/users/456',
  payload: { email: 'new@example.com' },
  ipAddress: '192.168.1.1',
  userAgent: 'Mozilla/5.0...',
  tags: 'user,updated',
  createdAt: Date,
  updatedAt: Date
}
```

## 🎯 Best Practices

1. **Always log sensitive operations**
   - User creation/deletion
   - Permission changes
   - Configuration changes
   - Failed login attempts

2. **Use meaningful event names**
   - Use snake_case: `user_registered`, `password_reset`
   - Be specific: `admin_permission_granted` vs `updated`

3. **Store relevant old/new values**
   - Don't log passwords or sensitive data
   - Log changes that matter for auditing

4. **Use tags for categorization**
   - `security` - Security-related events
   - `admin` - Admin actions
   - `critical` - Critical operations

5. **Regular cleanup**
   - Set retention policy (e.g., 90 days)
   - Archive old logs if needed
   - Monitor disk space

## 📚 SQL Queries

### View recent audit logs

```sql
SELECT * FROM v_recent_audit_logs LIMIT 100;
```

### Get user activity

```sql
SELECT * FROM audit_logs
WHERE user_id = 'user-123'
ORDER BY created_at DESC;
```

### Get failed logins

```sql
SELECT * FROM audit_logs
WHERE event = 'login_failed'
  AND created_at > DATE_SUB(NOW(), INTERVAL 1 DAY);
```

### Get audit statistics

```sql
CALL sp_get_audit_stats('2024-01-01', '2024-12-31');
```

## 🔒 Security Considerations

1. **Access Control**: Restrict audit log access to admins only
2. **Immutable**: Audit logs should never be updated, only created
3. **Retention**: Define and enforce retention policies
4. **Privacy**: Don't log sensitive data (passwords, tokens, PII)
5. **Monitoring**: Alert on suspicious patterns in audit logs
