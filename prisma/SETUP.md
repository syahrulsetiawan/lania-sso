# Prisma Setup Guide - Without Migrations

This guide shows how to setup Prisma with MySQL **without using migrations**.

## 📋 Prerequisites

- MySQL 8.0+ installed and running
- Database created: `lania_sso`
- Node.js 18+ installed

## 🚀 Step-by-Step Setup

### Step 1: Create Database

Login to MySQL and create the database:

```bash
mysql -u root -p
```

```sql
CREATE DATABASE lania_sso CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
EXIT;
```

### Step 2: Configure Environment

Create `.env` file in project root:

```env
DATABASE_URL="mysql://root:your_password@localhost:3306/lania_sso"
```

Replace:

- `root` with your MySQL username
- `your_password` with your MySQL password
- `localhost:3306` with your MySQL host and port
- `lania_sso` with your database name

### Step 3: Execute Schema SQL

Import the database schema:

```bash
mysql -u root -p lania_sso < prisma/schema.sql
```

Or using MySQL Workbench/phpMyAdmin:

1. Open `prisma/schema.sql`
2. Execute the entire script

### Step 4: Verify Tables Created

```sql
USE lania_sso;
SHOW TABLES;
```

You should see:

- `users`
- `user_profiles`
- `sessions`
- `refresh_tokens`
- `audit_logs`
- `system_configs`

### Step 5: Generate Prisma Client

```bash
npx prisma generate
```

This will:

- Read `prisma/schema.prisma`
- Connect to your database (using DATABASE_URL)
- Generate TypeScript types in `node_modules/@prisma/client`
- Create type-safe database client

### Step 6: Verify Prisma Client

```bash
npx prisma studio
```

This opens a GUI at `http://localhost:5555` to browse your database.

## ✅ Verification

Test the connection by running:

```bash
npm run start:dev
```

You should see in logs:

```
✅ Database connected successfully
```

## 📝 Sample Usage

After setup, you can use Prisma in your services:

```typescript
import { Injectable } from '@nestjs/common';
import { PrismaService } from './prisma/prisma.service';

@Injectable()
export class UserService {
  constructor(private prisma: PrismaService) {}

  async getUsers() {
    return this.prisma.user.findMany({
      select: {
        id: true,
        email: true,
        username: true,
        fullName: true,
      },
    });
  }
}
```

## 🔄 Making Schema Changes

When you need to modify the database schema:

### Option 1: Manual SQL (Recommended)

1. Write ALTER TABLE statement:

```sql
ALTER TABLE users ADD COLUMN phone VARCHAR(20) AFTER full_name;
```

2. Execute in MySQL:

```bash
mysql -u root -p lania_sso -e "ALTER TABLE users ADD COLUMN phone VARCHAR(20);"
```

3. Update `prisma/schema.prisma`:

```prisma
model User {
  // ... existing fields
  phone String? @db.VarChar(20)
  // ... rest
}
```

4. Update `prisma/schema.sql` for future reference

5. Regenerate Prisma Client:

```bash
npx prisma generate
```

### Option 2: Using Prisma DB Pull

1. Make changes in MySQL directly

2. Pull schema changes:

```bash
npx prisma db pull
```

This will update `schema.prisma` to match your database.

3. Regenerate client:

```bash
npx prisma generate
```

## 🛠️ Useful Commands

### View Current Database Schema

```bash
npx prisma db pull
```

### Validate Schema File

```bash
npx prisma validate
```

### Format Schema File

```bash
npx prisma format
```

### Open Database GUI

```bash
npx prisma studio
```

### Generate Client Types

```bash
npx prisma generate
```

## 🐛 Troubleshooting

### Error: Can't reach database server

Check:

1. MySQL is running: `sudo systemctl status mysql`
2. DATABASE_URL is correct in `.env`
3. User has permission to access database
4. Firewall allows connection

### Error: Table doesn't exist

1. Verify tables exist:

```sql
SHOW TABLES;
```

2. Re-run schema.sql:

```bash
mysql -u root -p lania_sso < prisma/schema.sql
```

### Error: @prisma/client not generated

Run:

```bash
npx prisma generate
```

### Error: Version mismatch

Ensure Prisma versions match:

```bash
npm list @prisma/client prisma
```

Update if needed:

```bash
npm install @prisma/client@latest prisma@latest
```

## 📚 Additional Resources

- [Prisma Client API Reference](https://www.prisma.io/docs/reference/api-reference/prisma-client-reference)
- [Prisma Schema Reference](https://www.prisma.io/docs/reference/api-reference/prisma-schema-reference)
- [MySQL Data Types](https://dev.mysql.com/doc/refman/8.0/en/data-types.html)

## ⚠️ Important Notes

1. **No Migrations**: This project does NOT use `prisma migrate`
2. **Manual Updates**: All schema changes are manual via SQL
3. **Version Control**: Keep `schema.sql` updated and in git
4. **Backup**: Always backup before schema changes
5. **Testing**: Test schema changes in dev environment first
