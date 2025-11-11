# 🚀 Laniakea SSO - Enterprise Authentication System

<p align="center">
  <strong>Production-ready Single Sign-On (SSO) service built with NestJS, Fastify, Prisma, and MySQL</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/NestJS-11.0-red" alt="NestJS" />
  <img src="https://img.shields.io/badge/Fastify-5.6-black" alt="Fastify" />
  <img src="https://img.shields.io/badge/Prisma-6.19-blue" alt="Prisma" />
  <img src="https://img.shields.io/badge/MySQL-8.0-orange" alt="MySQL" />
  <img src="https://img.shields.io/badge/TypeScript-5.0-blue" alt="TypeScript" />
</p>

---

## ✨ Features

### 🔐 Authentication

- ✅ **JWT Authentication** - Access token (1 hour) + Refresh token (7 days)
- ✅ **Token Rotation** - Secure refresh token rotation
- ✅ **Password Reset** - Email-based password recovery
- ✅ **Account Locking** - Auto-lock after failed login attempts
- ✅ **Multi-device Support** - Session management per device
- ✅ **Logout All** - Terminate all sessions at once

### 🛡️ Security

- ✅ **Bcrypt Hashing** - Secure password storage (10 rounds)
- ✅ **Progressive Lockout** - Smart brute force protection
  - 🔸 1-5 failed attempts: 5 minute temporary lock
  - 🔸 6-10 failed attempts: 15 minute temporary lock
  - 🔸 11+ failed attempts: Permanent lock + 24h force logout
- ✅ **JWT Middleware Protection** - Validates locked/suspended users
- ✅ **Session Tracking** - IP address, user agent, device tracking
- ✅ **Geolocation** - Latitude/longitude support
- ✅ **Rate Limiting** - Protection against brute force
- ✅ **Helmet.js** - Security headers
- ✅ **CORS** - Configurable cross-origin requests

### 📊 Audit Trail

- ✅ **Comprehensive Logging** - All operations logged to database
- ✅ **Login/Logout Events** - Track user authentication
- ✅ **Failed Attempts** - Monitor security threats with lockout levels
- ✅ **Password Changes** - Audit password modifications
- ✅ **Admin Actions** - Track administrative operations
- ✅ **Lockout Events** - Progressive lockout tracking (5min/15min/permanent)

### 📧 Email Service

- ✅ **Password Reset Emails** - Beautiful HTML templates
- ✅ **SMTP Ready** - Easy integration with mail providers
- ✅ **Development Mode** - Console logging for testing

### 🏢 Multi-tenancy

- ✅ **Tenant Management** - Support multiple organizations
- ✅ **Tenant Configuration** - Custom settings per tenant
- ✅ **Tenant Licensing** - License management system
- ✅ **User-Tenant Relations** - Many-to-many user assignments

---

## 🚀 Quick Start

### Prerequisites

- Node.js 18+
- MySQL 8.0+
- npm or yarn

### Installation

```bash
# 1. Install dependencies
npm install
npm install uuid
npm install -D @types/uuid

# 2. Configure environment
cp .env.example .env
# Edit .env and set your DATABASE_URL and JWT_SECRET

# 3. Import database
mysql -u root -p lania_sso < sso.sql

# 4. Generate Prisma client
npx prisma generate

# 5. Run application
npm run start:dev
```

Server runs at: **http://localhost:3000**

---

## 📖 Documentation

- 📘 **[SUMMARY.md](./SUMMARY.md)** - Project overview & completion status
- 📗 **[SETUP.md](./SETUP.md)** - Detailed setup & installation guide
- 📙 **[AUTH-API.md](./AUTH-API.md)** - Complete API documentation
- 📕 **[INTEGRATION.md](./INTEGRATION.md)** - Integration guide for other services

---

## 🔌 API Endpoints

All endpoints are prefixed with `/api/v1/auth`

| Method | Endpoint           | Description                | Auth Required |
| ------ | ------------------ | -------------------------- | ------------- |
| POST   | `/login`           | User login                 | ❌            |
| POST   | `/refresh`         | Refresh access token       | ❌            |
| POST   | `/forgot-password` | Request password reset     | ❌            |
| POST   | `/reset-password`  | Reset password with token  | ❌            |
| POST   | `/logout`          | Logout from current device | ✅            |
| POST   | `/logout-all`      | Logout from all devices    | ✅            |

### Example: Login

```bash
curl -X POST http://localhost:3000/api/v1/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "usernameOrEmail": "johndoe",
    "password": "SecurePassword123!",
    "deviceName": "Chrome on Windows"
  }'
```

**Response:**

```json
{
  "success": true,
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "a1b2c3d4e5f6...",
    "expiresIn": 3600,
    "tokenType": "Bearer",
    "user": {
      "id": "550e8400-e29b-41d4-a716-446655440000",
      "name": "John Doe",
      "username": "johndoe",
      "email": "john@example.com"
    }
  }
}
```

See **[AUTH-API.md](./AUTH-API.md)** for complete API documentation.

---

## 🏗️ Architecture

### Tech Stack

- **Framework**: NestJS 11.0 (Enterprise-grade Node.js framework)
- **HTTP Server**: Fastify 5.6 (2x faster than Express)
- **ORM**: Prisma 6.19 (Type-safe database client)
- **Database**: MySQL 8.0 (Production database)
- **Authentication**: JWT with refresh token rotation
- **Logging**: Winston with daily rotation
- **Validation**: class-validator + class-transformer

### Project Structure

```
src/
├── auth/                    # Authentication module
│   ├── dto/                # Data Transfer Objects
│   ├── auth.controller.ts  # 6 API endpoints
│   ├── auth.service.ts     # Business logic
│   ├── auth.module.ts      # Module configuration
│   └── email.service.ts    # Email service
├── audit/                  # Audit trail module
│   ├── audit.service.ts    # Audit logging
│   └── audit.module.ts
├── prisma/                 # Database module
│   ├── prisma.service.ts   # Database connection
│   └── prisma.module.ts
├── common/                 # Shared utilities
│   ├── guards/            # JWT auth guard
│   ├── filters/           # Exception filters
│   ├── interceptors/      # Response interceptors
│   └── logger/            # Winston configuration
└── main.ts                # Application bootstrap

prisma/
└── schema.prisma          # Database schema (16 tables)
```

---

## 🗄️ Database Schema

### Core Tables

- **users** - User accounts and credentials
- **sessions** - Active user sessions
- **refresh_tokens** - Refresh token management
- **password_reset_tokens** - Password reset tokens
- **failed_login_attempts** - Security monitoring
- **audit_logs** - Comprehensive audit trail

### Multi-tenancy

- **tenants** - Organization management
- **tenant_has_user** - User-tenant relationships
- **tenant_configs** - Tenant-specific settings
- **tenant_licenses** - License management

### System

- **user_configs** - User preferences
- **core_licenses** - License definitions
- **core_services** - Service catalog
- **core_status_tenants** - Tenant status definitions

---

## 🔒 Security Features

### Password Security

- Bcrypt hashing with 10 rounds
- Strong password validation (8+ chars, uppercase, lowercase, number, special char)
- Password history (prevent reuse) - ready for implementation

### Session Security

- JWT access tokens (1 hour expiration)
- Refresh token rotation (old token revoked immediately)
- Device tracking (IP, user agent, device name)
- Geolocation support (latitude/longitude)
- Force logout after password change

### Account Protection

- Account locking after 5 failed attempts (configurable)
- Failed login tracking
- Suspicious activity monitoring
- Email enumeration prevention

### Audit Trail

- All authentication events logged
- User actions tracked
- Admin operations monitored
- Security incidents recorded

---

## ⚙️ Configuration

### Environment Variables

```bash
# Application
NODE_ENV=development
PORT=3000
API_PREFIX=api/v1

# Database
DATABASE_URL=mysql://root:password@localhost:3306/lania_sso

# JWT
JWT_SECRET=your-super-secret-jwt-key-minimum-32-characters
JWT_EXPIRES_IN=1h
JWT_REFRESH_EXPIRES_IN=7d

# Security
MAX_FAILED_LOGIN_ATTEMPTS=5
PASSWORD_RESET_EXPIRATION_MINUTES=60

# Email (optional)
MAIL_HOST=smtp.gmail.com
MAIL_PORT=587
MAIL_USER=your-email@gmail.com
MAIL_PASSWORD=your-app-password

# Frontend
FRONTEND_URL=http://localhost:3000
```

---

## 🧪 Testing

```bash
# Unit tests
npm run test

# E2E tests
npm run test:e2e

# Test coverage
npm run test:cov

# Manual testing with cURL
# See AUTH-API.md for examples
```

---

## 📦 Production Deployment

### 1. Build Application

```bash
npm run build
```

### 2. Run Production

```bash
npm run start:prod
```

### 3. Checklist

- [ ] Set strong JWT_SECRET (min 32 random characters)
- [ ] Configure SMTP for email service
- [ ] Enable HTTPS (use reverse proxy)
- [ ] Set up proper CORS origins
- [ ] Configure rate limiting
- [ ] Set up database backups
- [ ] Monitor audit logs
- [ ] Set up error tracking (Sentry, etc.)

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:

1. Fork the repository
2. Create feature branch (`git checkout -b feature/amazing-feature`)
3. Commit changes (`git commit -m 'Add amazing feature'`)
4. Push to branch (`git push origin feature/amazing-feature`)
5. Open Pull Request

---

## 📄 License

This project is proprietary software. All rights reserved.

---

## 🙏 Acknowledgments

Built with:

- [NestJS](https://nestjs.com/) - Progressive Node.js framework
- [Fastify](https://www.fastify.io/) - Fast web framework
- [Prisma](https://www.prisma.io/) - Next-generation ORM
- [Winston](https://github.com/winstonjs/winston) - Logging library

---

## 📞 Support

For issues, questions, or support:

- Create an issue in the repository
- Contact the development team

---

<p align="center">
  <strong>© 2025 Laniakea. All rights reserved.</strong>
</p>
$ npm install
```

## Compile and run the project

```bash
# development
$ npm run start

# watch mode
$ npm run start:dev

# production mode
$ npm run start:prod
```

## Run tests

```bash
# unit tests
$ npm run test

# e2e tests
$ npm run test:e2e

# test coverage
$ npm run test:cov
```

## Deployment

When you're ready to deploy your NestJS application to production, there are some key steps you can take to ensure it runs as efficiently as possible. Check out the [deployment documentation](https://docs.nestjs.com/deployment) for more information.

If you are looking for a cloud-based platform to deploy your NestJS application, check out [Mau](https://mau.nestjs.com), our official platform for deploying NestJS applications on AWS. Mau makes deployment straightforward and fast, requiring just a few simple steps:

```bash
$ npm install -g @nestjs/mau
$ mau deploy
```

With Mau, you can deploy your application in just a few clicks, allowing you to focus on building features rather than managing infrastructure.

## Resources

Check out a few resources that may come in handy when working with NestJS:

- Visit the [NestJS Documentation](https://docs.nestjs.com) to learn more about the framework.
- For questions and support, please visit our [Discord channel](https://discord.gg/G7Qnnhy).
- To dive deeper and get more hands-on experience, check out our official video [courses](https://courses.nestjs.com/).
- Deploy your application to AWS with the help of [NestJS Mau](https://mau.nestjs.com) in just a few clicks.
- Visualize your application graph and interact with the NestJS application in real-time using [NestJS Devtools](https://devtools.nestjs.com).
- Need help with your project (part-time to full-time)? Check out our official [enterprise support](https://enterprise.nestjs.com).
- To stay in the loop and get updates, follow us on [X](https://x.com/nestframework) and [LinkedIn](https://linkedin.com/company/nestjs).
- Looking for a job, or have a job to offer? Check out our official [Jobs board](https://jobs.nestjs.com).

## Support

Nest is an MIT-licensed open source project. It can grow thanks to the sponsors and support by the amazing backers. If you'd like to join them, please [read more here](https://docs.nestjs.com/support).

## Stay in touch

- Author - [Kamil Myśliwiec](https://twitter.com/kammysliwiec)
- Website - [https://nestjs.com](https://nestjs.com/)
- Twitter - [@nestframework](https://twitter.com/nestframework)

## License

Nest is [MIT licensed](https://github.com/nestjs/nest/blob/master/LICENSE).
