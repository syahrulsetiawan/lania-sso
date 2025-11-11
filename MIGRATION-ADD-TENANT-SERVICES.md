# Migration: Add Tenant Services Table

## Overview

Menambahkan table `tenant_has_service` untuk mapping many-to-many relationship antara tenants dan services.

## Database Changes

### New Table: `tenant_has_service`

```sql
CREATE TABLE `tenant_has_service`  (
  `tenant_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `service_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`tenant_id`, `service_key`) USING BTREE,
  INDEX `idx_tenant_id`(`tenant_id` ASC) USING BTREE,
  INDEX `idx_service_key`(`service_key` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;
```

### Foreign Keys (Optional)

```sql
ALTER TABLE `tenant_has_service`
  ADD CONSTRAINT `fk_tenant_service_tenant`
    FOREIGN KEY (`tenant_id`) REFERENCES `tenants` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_tenant_service_service`
    FOREIGN KEY (`service_key`) REFERENCES `core_services` (`key`) ON DELETE CASCADE;
```

## Prisma Schema Changes

### Model: `TenantHasService`

```prisma
model TenantHasService {
  tenantId   String    @map("tenant_id") @db.Char(36)
  serviceKey String    @map("service_key") @db.VarChar(255)
  createdAt  DateTime? @map("created_at") @db.Timestamp(0)
  updatedAt  DateTime? @map("updated_at") @db.Timestamp(0)

  tenant  Tenant      @relation(fields: [tenantId], references: [id], onDelete: Cascade)
  service CoreService @relation(fields: [serviceKey], references: [key], onDelete: Cascade)

  @@id([tenantId, serviceKey])
  @@index([tenantId])
  @@index([serviceKey])
  @@map("tenant_has_service")
}
```

### Updated Relations

**Tenant Model:**

```prisma
model Tenant {
  // ... existing fields
  services    TenantHasService[]
}
```

**CoreService Model:**

```prisma
model CoreService {
  // ... existing fields
  tenants TenantHasService[]
}
```

## API Changes

### GET `/api/v1/auth/me` - Enhanced Response

Sekarang return data lengkap termasuk:

- User configs
- Tenants with:
  - **Tenant configs** (NEW!)
  - **Tenant services** (NEW!)

#### New Response Structure:

```json
{
  "id": "user-id",
  "name": "John Doe",
  "email": "john@example.com",
  "userConfigs": [
    {
      "id": "config-id",
      "configKey": "theme",
      "configValue": "dark"
    }
  ],
  "tenants": [
    {
      "tenantId": "tenant-id",
      "isActive": true,
      "isOwner": true,
      "tenant": {
        "id": "tenant-id",
        "name": "My Company",
        "code": "MYCO",
        "logoPath": "/logos/company.png",
        "status": "active",
        "isActive": true,
        "configs": [
          {
            "id": "config-id",
            "configKey": "max_users",
            "configValue": "100",
            "configType": "number"
          }
        ],
        "services": [
          {
            "serviceKey": "admin_portal",
            "service": {
              "key": "admin_portal",
              "name": "Admin Portal",
              "description": "Administrative dashboard",
              "icon": "admin-icon.svg",
              "isActive": true
            }
          },
          {
            "serviceKey": "accounting",
            "service": {
              "key": "accounting",
              "name": "Accounting",
              "description": "Accounting module",
              "icon": "accounting-icon.svg",
              "isActive": true
            }
          }
        ]
      }
    }
  ]
}
```

## Migration Steps

### 1. Backup Database

```bash
mysqldump -u root -p lania_sso > backup_before_migration.sql
```

### 2. Run SQL Migration

**Option A: Import full sso.sql (includes new table)**

```bash
mysql -u root -p lania_sso < sso.sql
```

**Option B: Run only new table creation**

```sql
USE lania_sso;

DROP TABLE IF EXISTS `tenant_has_service`;
CREATE TABLE `tenant_has_service`  (
  `tenant_id` char(36) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `service_key` varchar(255) CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci NOT NULL,
  `created_at` timestamp NULL DEFAULT NULL,
  `updated_at` timestamp NULL DEFAULT NULL,
  PRIMARY KEY (`tenant_id`, `service_key`) USING BTREE,
  INDEX `idx_tenant_id`(`tenant_id` ASC) USING BTREE,
  INDEX `idx_service_key`(`service_key` ASC) USING BTREE
) ENGINE = InnoDB CHARACTER SET = utf8mb4 COLLATE = utf8mb4_unicode_ci ROW_FORMAT = Dynamic;
```

### 3. Generate Prisma Client

```bash
npx prisma generate
```

### 4. Uncomment Services Query

Di file `src/auth/auth.service.ts`, uncomment bagian services:

```typescript
// Before (commented):
// services: {
//   select: {
//     serviceKey: true,
//     service: { ... }
//   }
// }

// After (uncommented):
services: {
  select: {
    serviceKey: true,
    service: {
      select: {
        key: true,
        name: true,
        description: true,
        icon: true,
        isActive: true,
      },
    },
  },
}
```

### 5. Restart Application

```bash
npm run start:dev
```

## Seed Data Example

```sql
-- Insert sample services to tenant
INSERT INTO tenant_has_service (tenant_id, service_key, created_at, updated_at)
VALUES
  ('0fc42307-c7ae-4de3-a9c8-a58110ed63dc', 'admin_portal', NOW(), NOW()),
  ('0fc42307-c7ae-4de3-a9c8-a58110ed63dc', 'accounting', NOW(), NOW()),
  ('0fc42307-c7ae-4de3-a9c8-a58110ed63dc', 'finance', NOW(), NOW()),
  ('0fc42307-c7ae-4de3-a9c8-a58110ed63dc', 'management_stock', NOW(), NOW()),
  ('0fc42307-c7ae-4de3-a9c8-a58110ed63dc', 'procurement', NOW(), NOW()),
  ('0fc42307-c7ae-4de3-a9c8-a58110ed63dc', 'salesorder', NOW(), NOW());
```

## Verification

### 1. Check Table Created

```sql
SHOW TABLES LIKE 'tenant_has_service';
DESC tenant_has_service;
```

### 2. Test API Endpoint

```bash
curl -X GET http://localhost:3000/api/v1/auth/me \
  -H "Authorization: Bearer YOUR_ACCESS_TOKEN"
```

Expected response should include `configs` and `services` inside each tenant object.

## Rollback (if needed)

```sql
DROP TABLE IF EXISTS `tenant_has_service`;
```

Then run:

```bash
npx prisma generate
```

And revert code changes in `auth.service.ts`.

## Notes

- Table uses **composite primary key** (`tenant_id`, `service_key`)
- **Cascade delete**: Jika tenant atau service dihapus, relation otomatis terhapus
- **Indexed** untuk performa query yang optimal
- Data sudah include di response `/me` untuk frontend bisa dynamic service access

## Impact

✅ **No Breaking Changes** - Response backward compatible  
✅ **Performance** - Indexed queries  
✅ **Security** - Service access per tenant  
✅ **Frontend Ready** - Dynamic service rendering based on tenant
