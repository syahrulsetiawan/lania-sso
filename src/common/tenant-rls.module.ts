import { Module } from '@nestjs/common';
import { TenantRlsService } from './services/tenant-rls.service';
import { TenantContextMiddleware } from './middleware/tenant-context.middleware';
import { TenantRlsInterceptor } from './interceptors/tenant-rls.interceptor';
import { PrismaModule } from '../prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  providers: [TenantRlsService, TenantContextMiddleware, TenantRlsInterceptor],
  exports: [TenantRlsService, TenantContextMiddleware, TenantRlsInterceptor],
})
export class TenantRlsModule {}
