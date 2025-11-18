import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { PrismaModule } from './prisma';
import { AuditModule } from './audit';
import { AuthModule } from './auth/auth.module';
import { TenantsModule } from './tenants/tenants.module';
import { TenantRlsModule } from './common/tenant-rls.module';
import { RlsTestModule } from './rls-test/rls-test.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
      envFilePath: '.env',
    }),
    PrismaModule,
    TenantRlsModule,
    AuditModule,
    AuthModule,
    TenantsModule,
    RlsTestModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
