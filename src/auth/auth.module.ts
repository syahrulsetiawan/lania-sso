import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { AuthController } from './auth.controller';
import { AuthService } from './auth.service';
import { EmailService } from './email.service';
import { PrismaModule } from '../prisma/prisma.module';
import { AuditModule } from '../audit/audit.module';
import { TenantRlsModule } from '../common/tenant-rls.module';

/**
 * Authentication Module
 * Handles user authentication, authorization, and session management
 */
@Module({
  imports: [
    PrismaModule,
    AuditModule,
    TenantRlsModule,
    ConfigModule,
    JwtModule.registerAsync({
      imports: [ConfigModule],
      inject: [ConfigService],
      useFactory: async (configService: ConfigService) => ({
        secret: configService.get<string>(
          'JWT_SECRET',
          'your-super-secret-jwt-key-change-in-production',
        ),
        signOptions: {
          expiresIn: '1h', // Access token expires in 1 hour
        },
      }),
    }),
  ],
  controllers: [AuthController],
  providers: [AuthService, EmailService],
  exports: [AuthService, EmailService],
})
export class AuthModule {}
