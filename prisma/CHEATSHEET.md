# Prisma Quick Reference - MySQL

## 🎯 Common Operations

### Create (Insert)

```typescript
// Single record
const user = await prisma.user.create({
  data: {
    email: 'user@example.com',
    username: 'johndoe',
    password: hashedPassword,
    fullName: 'John Doe',
  },
});

// With relation
const user = await prisma.user.create({
  data: {
    email: 'user@example.com',
    username: 'johndoe',
    password: hashedPassword,
    fullName: 'John Doe',
    profile: {
      create: {
        phone: '+1234567890',
        timezone: 'Asia/Jakarta',
      },
    },
  },
  include: { profile: true },
});

// Multiple records
const users = await prisma.user.createMany({
  data: [
    { email: 'user1@example.com', username: 'user1', ... },
    { email: 'user2@example.com', username: 'user2', ... },
  ],
});
```

### Read (Select)

```typescript
// Find unique (by unique field)
const user = await prisma.user.findUnique({
  where: { email: 'user@example.com' },
});

// Find first matching
const user = await prisma.user.findFirst({
  where: { isActive: true },
  orderBy: { createdAt: 'desc' },
});

// Find many with filters
const users = await prisma.user.findMany({
  where: {
    isActive: true,
    email: { contains: '@example.com' },
  },
  orderBy: { createdAt: 'desc' },
  take: 10,
  skip: 0,
});

// Select specific fields
const users = await prisma.user.findMany({
  select: {
    id: true,
    email: true,
    fullName: true,
  },
});

// Include relations
const user = await prisma.user.findUnique({
  where: { id: userId },
  include: {
    profile: true,
    sessions: true,
  },
});

// Nested include
const user = await prisma.user.findUnique({
  where: { id: userId },
  include: {
    sessions: {
      where: { isActive: true },
      take: 5,
    },
  },
});
```

### Update

```typescript
// Update single record
const user = await prisma.user.update({
  where: { id: userId },
  data: {
    fullName: 'Updated Name',
    lastLoginAt: new Date(),
  },
});

// Update with relation
const user = await prisma.user.update({
  where: { id: userId },
  data: {
    fullName: 'Updated Name',
    profile: {
      update: {
        phone: '+9876543210',
      },
    },
  },
});

// Update many
const result = await prisma.user.updateMany({
  where: { isActive: false },
  data: { isVerified: false },
});

// Upsert (update or create)
const user = await prisma.user.upsert({
  where: { email: 'user@example.com' },
  update: { lastLoginAt: new Date() },
  create: {
    email: 'user@example.com',
    username: 'newuser',
    password: hashedPassword,
    fullName: 'New User',
  },
});
```

### Delete

```typescript
// Delete single
const user = await prisma.user.delete({
  where: { id: userId },
});

// Delete many
const result = await prisma.user.deleteMany({
  where: {
    isActive: false,
    createdAt: { lt: oneYearAgo },
  },
});

// Delete all (dangerous!)
await prisma.user.deleteMany({});
```

### Count & Aggregate

```typescript
// Count records
const count = await prisma.user.count();

// Count with filter
const activeCount = await prisma.user.count({
  where: { isActive: true },
});

// Aggregate
const result = await prisma.auditLog.aggregate({
  _count: true,
  _avg: { statusCode: true },
  where: {
    createdAt: {
      gte: new Date('2024-01-01'),
    },
  },
});

// Group by
const usersByDate = await prisma.user.groupBy({
  by: ['isActive'],
  _count: true,
});
```

## 🔍 Advanced Queries

### Filtering

```typescript
// Equals
where: { email: 'user@example.com' }

// Not equals
where: { email: { not: 'user@example.com' } }

// In array
where: { id: { in: ['id1', 'id2', 'id3'] } }

// Not in array
where: { id: { notIn: ['id1', 'id2'] } }

// Contains (LIKE %value%)
where: { email: { contains: 'example' } }

// Starts with (LIKE value%)
where: { email: { startsWith: 'admin' } }

// Ends with (LIKE %value)
where: { email: { endsWith: '@example.com' } }

// Greater than / Less than
where: {
  createdAt: { gt: yesterday },
  createdAt: { gte: yesterday },
  createdAt: { lt: tomorrow },
  createdAt: { lte: tomorrow },
}

// Between
where: {
  createdAt: {
    gte: startDate,
    lte: endDate,
  },
}

// AND condition
where: {
  AND: [
    { isActive: true },
    { isVerified: true },
  ],
}

// OR condition
where: {
  OR: [
    { email: { contains: 'admin' } },
    { username: { contains: 'admin' } },
  ],
}

// NOT condition
where: {
  NOT: {
    email: { endsWith: '@spam.com' },
  },
}

// Null check
where: { lastLoginAt: null }
where: { lastLoginAt: { not: null } }
```

### Pagination

```typescript
// Offset pagination
const users = await prisma.user.findMany({
  skip: (page - 1) * pageSize,
  take: pageSize,
  orderBy: { createdAt: 'desc' },
});

// Cursor-based pagination
const users = await prisma.user.findMany({
  take: 10,
  cursor: { id: lastUserId },
  skip: 1, // Skip the cursor
  orderBy: { id: 'asc' },
});
```

### Sorting

```typescript
// Single field
orderBy: { createdAt: 'desc' }

// Multiple fields
orderBy: [
  { isActive: 'desc' },
  { createdAt: 'desc' },
]

// Relation field
orderBy: {
  profile: {
    updatedAt: 'desc',
  },
}
```

## 🔄 Transactions

```typescript
// Sequential transaction
const [user, session] = await prisma.$transaction([
  prisma.user.create({ data: userData }),
  prisma.session.create({ data: sessionData }),
]);

// Interactive transaction
const result = await prisma.$transaction(async (tx) => {
  const user = await tx.user.create({ data: userData });

  const profile = await tx.userProfile.create({
    data: {
      userId: user.id,
      ...profileData,
    },
  });

  return { user, profile };
});

// With isolation level
await prisma.$transaction(
  async (tx) => {
    // Your operations
  },
  {
    isolationLevel: 'Serializable',
    maxWait: 5000,
    timeout: 10000,
  },
);
```

## 🎨 Relations

```typescript
// Create with nested create
const user = await prisma.user.create({
  data: {
    email: 'user@example.com',
    profile: {
      create: { phone: '123' },
    },
    sessions: {
      create: [
        { token: 'token1', ipAddress: '1.1.1.1' },
        { token: 'token2', ipAddress: '2.2.2.2' },
      ],
    },
  },
});

// Connect existing relations
await prisma.user.update({
  where: { id: userId },
  data: {
    sessions: {
      connect: { id: sessionId },
    },
  },
});

// Disconnect relations
await prisma.user.update({
  where: { id: userId },
  data: {
    sessions: {
      disconnect: { id: sessionId },
    },
  },
});

// Delete relations
await prisma.user.update({
  where: { id: userId },
  data: {
    sessions: {
      delete: { id: sessionId },
    },
  },
});
```

## 🛡️ Error Handling

```typescript
try {
  await prisma.user.create({ data: userData });
} catch (error: any) {
  // Unique constraint violation
  if (error.code === 'P2002') {
    console.log('Duplicate value:', error.meta?.target);
  }

  // Foreign key constraint violation
  if (error.code === 'P2003') {
    console.log('Foreign key failed');
  }

  // Record not found
  if (error.code === 'P2025') {
    console.log('Record not found');
  }
}
```

## 📊 Common Error Codes

- `P2002` - Unique constraint violation
- `P2003` - Foreign key constraint violation
- `P2025` - Record not found
- `P2014` - Required relation violation
- `P2000` - Value too long for column
- `P2011` - Null constraint violation

## 🚀 Performance Tips

```typescript
// ❌ Bad - N+1 query problem
const users = await prisma.user.findMany();
for (const user of users) {
  const profile = await prisma.userProfile.findUnique({
    where: { userId: user.id },
  });
}

// ✅ Good - Use include
const users = await prisma.user.findMany({
  include: { profile: true },
});

// ✅ Good - Select only needed fields
const users = await prisma.user.findMany({
  select: {
    id: true,
    email: true,
    profile: {
      select: { phone: true },
    },
  },
});

// ✅ Good - Use pagination
const users = await prisma.user.findMany({
  take: 100,
  skip: 0,
});

// ✅ Good - Use indexes (defined in schema)
const user = await prisma.user.findUnique({
  where: { email: 'user@example.com' }, // Uses index
});
```

## 📝 Raw Queries (When Needed)

```typescript
// Raw query
const users = await prisma.$queryRaw`
  SELECT * FROM users 
  WHERE email LIKE ${`%${search}%`}
  LIMIT 10
`;

// Execute raw SQL
await prisma.$executeRaw`
  UPDATE users 
  SET is_active = false 
  WHERE last_login_at < ${oneYearAgo}
`;

// Query with parameters
const email = 'user@example.com';
const user = await prisma.$queryRaw`
  SELECT * FROM users WHERE email = ${email}
`;
```
