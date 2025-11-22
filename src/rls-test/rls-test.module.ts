import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { RlsTestController } from './rls-test.controller';
import { TenantRlsModule } from '../common/tenant-rls.module';
import { PrismaModule } from '../prisma/prisma.module';

@Module({
  imports: [
    TenantRlsModule,
    PrismaModule,
    JwtModule.register({}), // Required for JwtAuthGuard
  ],
  controllers: [RlsTestController],
})
export class RlsTestModule {}
