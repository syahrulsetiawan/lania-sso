import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { ConfigModule } from '@nestjs/config';
import { TenantsController } from './tenants.controller';
import { TenantsService } from './tenants.service';
import { PrismaModule } from '../prisma/prisma.module';
import { AuditModule } from '../audit/audit.module';
import { TenantRlsModule } from '../common/tenant-rls.module';

@Module({
  imports: [
    PrismaModule,
    AuditModule,
    TenantRlsModule,
    ConfigModule,
    JwtModule.register({}), // Register JwtModule for JwtAuthGuard
  ],
  controllers: [TenantsController],
  providers: [TenantsService],
  exports: [TenantsService],
})
export class TenantsModule {}
