/**
 * Prisma Configuration for v7
 * Database connection URLs are now configured here instead of schema.prisma
 */

export default {
  datasources: {
    db: {
      url: process.env.DATABASE_URL,
    },
  },
};
