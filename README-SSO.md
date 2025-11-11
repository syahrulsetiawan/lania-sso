# Laniakea SSO Service

Enterprise-grade Single Sign-On (SSO) service built with NestJS, Fastify, Prisma, and comprehensive audit trail capabilities.

## 🚀 Features

### Core Architecture

- **NestJS Framework** - Progressive Node.js framework for scalable applications
- **Fastify** - High-performance web server (2x faster than Express)
- **Prisma ORM** - Type-safe database access with migrations
- **TypeScript** - Full type safety and modern JavaScript features

### Security & Performance

- ✅ **JWT Authentication** - Secure token-based authentication with refresh tokens
- ✅ **Helmet** - Security headers for protection against common vulnerabilities
- ✅ **Rate Limiting** - Protect against DDoS and brute-force attacks
- ✅ **CORS** - Configurable cross-origin resource sharing
- ✅ **Compression** - Gzip/Deflate response compression

### Development Experience

- ✅ **Winston Logger** - Professional logging with daily file rotation
- ✅ **Global Exception Filter** - Standardized error responses with WIB timezone
- ✅ **Response Interceptor** - Consistent API response format
- ✅ **Validation Pipe** - Automatic DTO validation with class-validator
- ✅ **Environment Configuration** - Centralized config management

## 📋 Prerequisites

- Node.js >= 18.x
- PostgreSQL >= 14.x
- npm or yarn

## 🛠️ Installation

1. Clone the repository

```bash
git clone <repository-url>
cd lania-sso
```

2. Install dependencies

```bash
npm install
```

3. Setup environment variables

```bash
cp .env.example .env
# Edit .env with your configuration
```

4. Setup database

```bash
npx prisma migrate dev
npx prisma generate
```

## 🚀 Running the Application

### Development Mode

```bash
npm run start:dev
```

### Production Mode

```bash
npm run build
npm run start:prod
```

### Debug Mode

```bash
npm run start:debug
```

## 📁 Project Structure

```
src/
├── common/
│   ├── filters/
│   │   └── http-exception.filter.ts    # Global exception handler
│   ├── guards/
│   │   └── jwt-auth.guard.ts           # JWT authentication guard
│   ├── interceptors/
│   │   └── response.interceptor.ts     # Response transformation
│   └── logger/
│       └── winston.config.ts           # Winston logger configuration
├── auth/                               # Authentication module
├── audit/                              # Audit trail module
├── prisma/                             # Prisma service and migrations
├── app.module.ts                       # Root module
└── main.ts                             # Application entry point
```

## 🔧 Configuration

### Environment Variables

Create a `.env` file with the following variables:

```env
# Application
NODE_ENV=development
PORT=3000
HOST=0.0.0.0

# CORS
CORS_ORIGIN=*

# Rate Limiting
RATE_LIMIT_MAX=100
RATE_LIMIT_WINDOW=15m

# JWT
JWT_SECRET=your-super-secret-jwt-key
JWT_EXPIRES_IN=1h
JWT_REFRESH_EXPIRES_IN=7d

# Database
DATABASE_URL=postgresql://user:password@localhost:5432/lania_sso
```

## 🧪 Testing

```bash
# Unit tests
npm run test

# E2E tests
npm run test:e2e

# Test coverage
npm run test:cov
```

## 📝 API Response Format

All API responses follow a consistent format:

### Success Response

```json
{
  "success": true,
  "data": { ... },
  "timestamp": "2025-11-10T15:30:00+07:00"
}
```

### Error Response

```json
{
  "success": false,
  "statusCode": 401,
  "message": "Invalid or expired token",
  "reason": "invalid_token",
  "path": "/api/v1/auth/profile",
  "timestamp": "2025-11-10T15:30:00+07:00"
}
```

## 🔒 Security Features

1. **JWT Authentication Guard** - Protects routes with JWT token validation
2. **Rate Limiting** - Prevents abuse with configurable rate limits
3. **Helmet** - Sets security headers (CSP, XSS protection, etc.)
4. **CORS** - Controlled cross-origin access
5. **Input Validation** - Automatic DTO validation with class-validator

## 📊 Logging

Logs are stored in the `logs/` directory with daily rotation:

- `YYYY-MM-DD-combined.log` - All logs
- `YYYY-MM-DD-error.log` - Error logs only

Logs are kept for 14 days with automatic compression.

## 🚦 Health Check

Access the health check endpoint:

```
GET http://localhost:3000/api/v1
```

## 📚 Additional Resources

- [NestJS Documentation](https://docs.nestjs.com)
- [Fastify Documentation](https://fastify.dev)
- [Prisma Documentation](https://www.prisma.io/docs)

## 📄 License

UNLICENSED - Private/Proprietary
