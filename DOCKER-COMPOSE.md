# Docker Compose Setup

## Quick Start

### 1. Start Services

```bash
docker-compose up -d
```

### 2. Check Status

```bash
docker-compose ps
```

### 3. View Logs

```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f lania-sso
docker-compose logs -f postgres
```

### 4. Stop Services

```bash
docker-compose down
```

### 5. Stop and Remove Volumes

```bash
docker-compose down -v
```

## Services

### PostgreSQL Database

- **Port**: 5432
- **User**: postgres
- **Password**: password
- **Database**: lania_sso
- **Volume**: postgres_data (persistent)

### Lania SSO API

- **Port**: 8001 (mapped to container port 3000)
- **API Endpoint**: http://localhost:8001/api/v1
- **Swagger Docs**: http://localhost:8001/api/docs
- **Health Check**: http://localhost:8001/api/v1

## Environment Variables

Edit `.env.docker` file to customize configuration:

```bash
# JWT Configuration
JWT_SECRET=your-secret-key
JWT_EXPIRES_IN=1h
JWT_REFRESH_EXPIRES_IN=7d

# CORS
CORS_ORIGIN=http://localhost:3000
CORS_CREDENTIALS=true

# Rate Limiting
RATE_LIMIT_MAX=100
RATE_LIMIT_WINDOW=15m
```

## Database Initialization

The database is automatically initialized with:

- `lania_common_postgres.sql` - Common schema
- `lania_sso_postgres.sql` - SSO schema

These files are executed on first startup.

## Useful Commands

### Rebuild Application

```bash
docker-compose up -d --build lania-sso
```

### Access PostgreSQL CLI

```bash
docker-compose exec postgres psql -U postgres -d lania_sso
```

### Run Prisma Migrations

```bash
docker-compose exec lania-sso npx prisma migrate deploy
```

### Restart Services

```bash
docker-compose restart
```

## Troubleshooting

### Database Connection Issues

```bash
# Check if database is healthy
docker-compose exec postgres pg_isready -U postgres

# View database logs
docker-compose logs postgres
```

### Application Not Starting

```bash
# Check application logs
docker-compose logs lania-sso

# Rebuild the image
docker-compose build --no-cache lania-sso
docker-compose up -d lania-sso
```

### Port Already in Use

Change the ports in `docker-compose.yml`:

```yaml
ports:
  - '8001:3000' # Change 8001 to 8001
```

## Production Deployment

For production, update environment variables:

1. Generate a strong JWT secret:

```bash
openssl rand -base64 32
```

2. Update `.env.docker` with production values
3. Configure proper CORS origins
4. Set up SSL/TLS certificates
5. Use secrets management for sensitive data

## Monitoring

### Check Container Health

```bash
docker-compose ps
```

### View Resource Usage

```bash
docker stats
```

### Inspect Container

```bash
docker-compose exec lania-sso sh
```
