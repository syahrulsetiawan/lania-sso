import { NestFactory } from '@nestjs/core';
import {
  FastifyAdapter,
  NestFastifyApplication,
} from '@nestjs/platform-fastify';
import { ValidationPipe, Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import helmet from '@fastify/helmet';
import compress from '@fastify/compress';
import rateLimit from '@fastify/rate-limit';
import { AppModule } from './app.module';
import { HttpExceptionFilter } from './common/filters/http-exception.filter';
import { ResponseInterceptor } from './common/interceptors/response.interceptor';

/**
 * Bootstrap the NestJS application with Fastify
 * Configures security, validation, logging, and global filters/interceptors
 */
async function bootstrap() {
  const logger = new Logger('Bootstrap');

  // Create Fastify adapter with custom options
  const fastifyAdapter = new FastifyAdapter({
    logger: false, // Disable Fastify's default logger
    trustProxy: true, // Trust proxy headers for correct IP detection
  });

  // Get Fastify instance before creating NestJS app
  const fastifyInstance = fastifyAdapter.getInstance();

  // Register Fastify plugins before creating NestJS app
  // Security: Helmet middleware
  await fastifyInstance.register(helmet as any, {
    contentSecurityPolicy: {
      directives: {
        defaultSrc: ["'self'"],
        styleSrc: ["'self'", "'unsafe-inline'"],
        scriptSrc: ["'self'"],
        imgSrc: ["'self'", 'data:', 'https:'],
      },
    },
  });

  // Performance: Compression middleware
  await fastifyInstance.register(compress as any, {
    encodings: ['gzip', 'deflate'],
  });

  // Create NestJS application with Fastify
  const app = await NestFactory.create<NestFastifyApplication>(
    AppModule,
    fastifyAdapter,
  );

  // Get ConfigService for environment variables
  const configService = app.get(ConfigService);

  // ========================================================================
  // ⚠️ CORS CONFIGURATION
  // ========================================================================
  // 🔧 DEVELOPMENT MODE: CORS disabled for local testing
  // ⚠️ TODO: UNCOMMENT BEFORE PRODUCTION DEPLOYMENT!
  // ========================================================================

  // Enable CORS - PRODUCTION CONFIGURATION (COMMENTED FOR DEVELOPMENT)
  // 🚨 UNCOMMENT THIS BEFORE PRODUCTION! 🚨
  /*
  app.enableCors({
    origin: configService.get<string>('CORS_ORIGIN') || 'http://localhost:3000',
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  });
  */

  // 🔓 DEVELOPMENT ONLY - ALLOW ALL ORIGINS
  // 🚨 REMOVE THIS IN PRODUCTION! 🚨
  app.enableCors({
    origin: true, // Allow all origins (DEVELOPMENT ONLY!)
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  });

  // ========================================================================
  // END CORS CONFIGURATION
  // ========================================================================

  // Security: Rate limiting (register after app creation)
  await fastifyInstance.register(rateLimit as any, {
    max: configService.get<number>('RATE_LIMIT_MAX') || 100,
    timeWindow: configService.get<string>('RATE_LIMIT_WINDOW') || '15m',
    errorResponseBuilder: () => ({
      success: false,
      statusCode: 429,
      message: 'Too many requests, please try again later',
      reason: 'rate_limit_exceeded',
    }),
  });

  // Global validation pipe
  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true, // Strip non-whitelisted properties
      forbidNonWhitelisted: true, // Throw error if non-whitelisted properties exist
      transform: true, // Automatically transform payloads to DTO instances
      transformOptions: {
        enableImplicitConversion: true, // Allow implicit type conversion
      },
    }),
  );

  // Global exception filter
  app.useGlobalFilters(new HttpExceptionFilter());

  // Global response interceptor
  app.useGlobalInterceptors(new ResponseInterceptor());

  // Set global prefix for all routes
  app.setGlobalPrefix('api/v1');

  // Setup Swagger API Documentation
  const swaggerConfig = new DocumentBuilder()
    .setTitle('Laniakea SSO API')
    .setDescription('Enterprise Single Sign-On Authentication API')
    .setVersion('1.0.0')
    .addBearerAuth(
      {
        type: 'http',
        scheme: 'bearer',
        bearerFormat: 'JWT',
        name: 'JWT',
        description: 'Enter JWT access token',
        in: 'header',
      },
      'JWT-auth',
    )
    .addTag('Authentication', 'User authentication endpoints')
    .addTag('Users', 'User management endpoints')
    .addTag('Sessions', 'Session management endpoints')
    .addTag('Audit', 'Audit trail endpoints')
    .build();

  const document = SwaggerModule.createDocument(app, swaggerConfig);
  SwaggerModule.setup('api/docs', app, document, {
    swaggerOptions: {
      persistAuthorization: true,
      tagsSorter: 'alpha',
      operationsSorter: 'alpha',
    },
  });

  // Get port from environment or use default
  const port = configService.get<number>('PORT') || 3000;
  const host = configService.get<string>('HOST') || '0.0.0.0';

  // Start the server
  await app.listen(port, host);

  // Log startup message
  logger.log(`🚀 Application is running on: http://${host}:${port}/api/v1`);
  logger.log(`📚 Swagger docs available at: http://${host}:${port}/api/docs`);
  logger.log(
    `📝 Environment: ${configService.get<string>('NODE_ENV') || 'development'}`,
  );
}

bootstrap().catch((err) => {
  const logger = new Logger('Bootstrap');
  logger.error('❌ Error starting application', err);
  process.exit(1);
});
