import { NestFactory } from '@nestjs/core';
import {
  FastifyAdapter,
  NestFastifyApplication,
} from '@nestjs/platform-fastify';
import { ValidationPipe } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { SwaggerModule, DocumentBuilder } from '@nestjs/swagger';
import helmet from '@fastify/helmet';
import compress from '@fastify/compress';
import rateLimit from '@fastify/rate-limit';
import { AppModule } from './app.module';
import { HttpExceptionFilter } from './common/filters/http-exception.filter';
import { ResponseInterceptor } from './common/interceptors/response.interceptor';

/**
 * Creates and configures the NestJS Fastify application without binding to a port.
 * Can be reused for both long-lived servers and application bootstrap.
 */
export async function createApp(): Promise<NestFastifyApplication> {
  const fastifyAdapter = new FastifyAdapter({
    logger: false,
    trustProxy: true,
  });

  const fastifyInstance = fastifyAdapter.getInstance();

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

  await fastifyInstance.register(compress as any, {
    encodings: ['gzip', 'deflate'],
  });

  const app = await NestFactory.create<NestFastifyApplication>(
    AppModule,
    fastifyAdapter,
  );

  const configService = app.get(ConfigService);

  // NOTE: CORS is currently wide open for development.
  // Update before deploying to production if specific origins are required.
  app.enableCors({
    origin: true,
    credentials: true,
    methods: ['GET', 'POST', 'PUT', 'PATCH', 'DELETE', 'OPTIONS'],
    allowedHeaders: ['Content-Type', 'Authorization'],
  });

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

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      transformOptions: {
        enableImplicitConversion: true,
      },
    }),
  );

  app.useGlobalFilters(new HttpExceptionFilter());
  app.useGlobalInterceptors(new ResponseInterceptor());

  app.setGlobalPrefix('api/v1');

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

  await app.init();
  await fastifyInstance.ready();

  return app;
}
