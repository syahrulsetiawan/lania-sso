# Prisma Database Setup

This project uses **MySQL** database with **Prisma ORM** for type-safe database access.

⚠️ **Important:** This project does NOT use Prisma migrations. The database schema must be created manually using the provided SQL script.

## 📁 Files

```
prisma/
├── schema.prisma    # Prisma schema definition
├── schema.sql       # Manual MySQL schema creation script
└── README.md        # This file
```

## 🚀 Quick Start

### 1. Setup MySQL Database

Create a MySQL database for the project:

```sql
CREATE DATABASE lania_sso CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
```

### 2. Configure Database Connection

Create a `.env` file in the project root with your database URL:

```env
DATABASE_URL="mysql://username:password@localhost:3306/lania_sso"
```

### 3. Create Database Schema

Execute the SQL script to create all tables:

```bash
mysql -u username -p lania_sso < prisma/schema.sql
```

Or import via MySQL client:

```sql
SOURCE /path/to/prisma/schema.sql;
```

### 4. Generate Prisma Client

After the schema is created, generate the Prisma Client:

```bash
npx prisma generate
```

This will generate TypeScript types based on your database schema.

## 📊 Database Schema

### Tables

1. **users** - Core user accounts
2. **user_profiles** - Extended user information
3. **sessions** - Active user sessions
4. **refresh_tokens** - JWT refresh tokens
5. **audit_logs** - Security audit trail
6. **system_configs** - Application configuration

### Sample Data

The SQL script includes optional sample data:

- Sample admin user (update the bcrypt hash before using)
- Basic system configurations

## 🔧 Usage in NestJS

### Inject PrismaService

```typescript
import { Injectable } from '@nestjs/common';
import { PrismaService } from './prisma/prisma.service';

@Injectable()
export class UserService {
  constructor(private readonly prisma: PrismaService) {}

  async findUserByEmail(email: string) {
    return this.prisma.user.findUnique({
      where: { email },
      include: { profile: true },
    });
  }

  async createUser(data: CreateUserDto) {
    return this.prisma.user.create({
      data: {
        id: uuidv4(),
        email: data.email,
        username: data.username,
        password: hashedPassword,
        fullName: data.fullName,
      },
    });
  }
}
```

### PrismaService Features

- ✅ Auto-connect on module init
- ✅ Auto-disconnect on module destroy
- ✅ Query logging in development
- ✅ Error logging
- ✅ Global module (available everywhere)

## 📝 Prisma Commands

### Generate Prisma Client

```bash
npx prisma generate
```

### Open Prisma Studio (Database GUI)

```bash
npx prisma studio
```

### Validate Schema

```bash
npx prisma validate
```

### Format Schema

```bash
npx prisma format
```

## 🔄 Schema Sync (Without Migrations)

Since this project doesn't use migrations, you need to:

1. **Modify** `schema.sql` when making schema changes
2. **Execute** the SQL changes manually in your database
3. **Update** `schema.prisma` to match
4. **Regenerate** Prisma Client: `npx prisma generate`

### Example Workflow:

```bash
# 1. Modify schema.sql (add new column)
# 2. Execute SQL in database
mysql -u user -p lania_sso -e "ALTER TABLE users ADD COLUMN phone VARCHAR(20);"

# 3. Update schema.prisma
# 4. Regenerate client
npx prisma generate
```

## 🎯 Best Practices

### 1. Use Transactions for Complex Operations

```typescript
async transferData(fromId: string, toId: string) {
  return this.prisma.$transaction(async (tx) => {
    const from = await tx.user.update({
      where: { id: fromId },
      data: { balance: { decrement: 100 } },
    });

    const to = await tx.user.update({
      where: { id: toId },
      data: { balance: { increment: 100 } },
    });

    return { from, to };
  });
}
```

### 2. Use Select for Performance

```typescript
// ❌ Bad - fetches all fields
const user = await this.prisma.user.findUnique({ where: { id } });

// ✅ Good - only fetch needed fields
const user = await this.prisma.user.findUnique({
  where: { id },
  select: { id: true, email: true, fullName: true },
});
```

### 3. Use Indexes for Queries

The schema includes proper indexes. Always query using indexed fields:

```typescript
// ✅ Good - uses index
await this.prisma.user.findUnique({ where: { email } });

// ⚠️ Slow - no index (full table scan)
await this.prisma.user.findFirst({ where: { fullName } });
```

### 4. Handle Unique Constraint Errors

```typescript
try {
  await this.prisma.user.create({ data: { email, ... } });
} catch (error) {
  if (error.code === 'P2002') {
    throw new ConflictException('Email already exists');
  }
  throw error;
}
```

## 🗄️ Database Maintenance

### Cleanup Expired Sessions

```sql
CALL sp_cleanup_expired_sessions();
```

### Cleanup Expired Refresh Tokens

```sql
CALL sp_cleanup_expired_refresh_tokens();
```

### View Active Sessions

```sql
SELECT * FROM v_active_sessions;
```

### View Login History

```sql
SELECT * FROM v_user_login_history LIMIT 100;
```

## 📚 Resources

- [Prisma Documentation](https://www.prisma.io/docs)
- [Prisma Client API](https://www.prisma.io/docs/reference/api-reference/prisma-client-reference)
- [Prisma with NestJS](https://docs.nestjs.com/recipes/prisma)
- [MySQL Documentation](https://dev.mysql.com/doc/)

## ⚠️ Important Notes

1. **No Migrations**: This project intentionally does not use Prisma Migrate
2. **Manual Schema Updates**: All schema changes must be applied manually via SQL
3. **Prisma Client**: Only used for type-safe database queries
4. **Production**: Ensure schema.sql is version controlled and tested
