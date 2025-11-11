# Main.ts Integration Guide

## ✅ What Has Been Integrated

### 1. **Fastify Adapter**

- High-performance HTTP server (2x faster than Express)
- Configured with trust proxy for proper IP detection
- Custom logger disabled in favor of Winston

### 2. **Security Middleware**

#### Helmet

- Content Security Policy (CSP)
- XSS Protection
- Prevents clickjacking
- MIME type sniffing protection

#### Rate Limiting

- Default: 100 requests per 15 minutes
- Configurable via environment variables
- Custom error response with `reason` field
- Returns 429 status code when limit exceeded

#### CORS

- Configurable origins via `CORS_ORIGIN` env variable
- Supports credentials
- Allowed methods: GET, POST, PUT, PATCH, DELETE, OPTIONS
- Allowed headers: Content-Type, Authorization

### 3. **Global Pipes**

#### ValidationPipe

- **whitelist**: Automatically strips unknown properties
- **forbidNonWhitelisted**: Throws error if unknown properties sent
- **transform**: Converts plain objects to DTO instances
- **enableImplicitConversion**: Auto-converts types (string to number, etc.)

### 4. **Global Filters**

#### HttpExceptionFilter

Location: `src/common/filters/http-exception.filter.ts`

Features:

- Catches all `HttpException` instances
- Standardizes error response format
- Extracts custom `reason` field from exceptions
- Converts timestamp to WIB timezone (Asia/Jakarta)
- Includes request path in error response

Example Usage in Controllers:

```typescript
throw new UnauthorizedException({
  message: 'Invalid credentials',
  reason: 'invalid_credentials',
});
```

### 5. **Global Interceptors**

#### ResponseInterceptor

Location: `src/common/interceptors/response.interceptor.ts`

Features:

- Wraps all successful responses in consistent format
- Recursively converts all Date objects to WIB timezone strings
- Adds `success: true` flag
- Includes timestamp in WIB timezone

### 6. **Performance Optimization**

#### Compression

- Gzip and Deflate encoding
- Automatic compression for text responses
- Improves bandwidth usage

### 7. **Configuration Management**

#### ConfigService Integration

- Global ConfigModule for environment variables
- Type-safe configuration access
- Default fallback values

### 8. **Global API Prefix**

- All routes prefixed with `/api/v1`
- Example: `GET /api/v1/auth/login`

## 📋 Environment Variables Used in main.ts

```env
NODE_ENV=development          # Application environment
PORT=3000                     # Server port
HOST=0.0.0.0                  # Server host
CORS_ORIGIN=*                 # Allowed CORS origins
RATE_LIMIT_MAX=100           # Max requests per window
RATE_LIMIT_WINDOW=15m        # Rate limit time window
```

## 🔧 How to Use

### Protecting Routes with JWT Guard

```typescript
import { Controller, Get, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from './common/guards/jwt-auth.guard';

@Controller('profile')
export class ProfileController {
  @Get()
  @UseGuards(JwtAuthGuard)
  getProfile(@Request() req) {
    // req.user contains the JWT payload
    return { userId: req.user.sub };
  }
}
```

### Using ConfigService

```typescript
import { Injectable } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';

@Injectable()
export class MyService {
  constructor(private configService: ConfigService) {}

  getJwtSecret() {
    return this.configService.get<string>('JWT_SECRET');
  }
}
```

### Custom Error Responses

```typescript
// In your service or controller
throw new BadRequestException({
  message: 'Email already exists',
  reason: 'duplicate_email'
});

// Client receives:
{
  "success": false,
  "statusCode": 400,
  "message": "Email already exists",
  "reason": "duplicate_email",
  "path": "/api/v1/auth/register",
  "timestamp": "2025-11-10T15:30:00+07:00"
}
```

## 🚀 Startup Process

1. Create Fastify adapter with custom options
2. Get Fastify instance
3. Register Helmet middleware
4. Register Compression middleware
5. Create NestJS application
6. Get ConfigService
7. Enable CORS
8. Register Rate Limiting
9. Apply ValidationPipe globally
10. Apply HttpExceptionFilter globally
11. Apply ResponseInterceptor globally
12. Set global API prefix `/api/v1`
13. Start server and log startup message

## ✨ Best Practices Implemented

1. ✅ **Type Safety** - Full TypeScript typing throughout
2. ✅ **Environment Config** - No hardcoded values
3. ✅ **Error Handling** - Centralized and consistent
4. ✅ **Response Format** - Standardized across all endpoints
5. ✅ **Security First** - Multiple layers of protection
6. ✅ **Performance** - Fastify + Compression
7. ✅ **Logging** - Professional logging setup (Winston)
8. ✅ **Validation** - Automatic DTO validation
9. ✅ **Documentation** - Clear comments and JSDoc

## 📝 Notes

- Winston logger is configured but uses NestJS built-in Logger in main.ts for simplicity
- All timestamps are automatically converted to WIB (Asia/Jakarta, UTC+7)
- Rate limiting uses Fastify's rate-limit plugin
- Global prefix can be changed by modifying `app.setGlobalPrefix('api/v1')`
