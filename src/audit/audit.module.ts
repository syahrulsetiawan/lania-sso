import { Module } from '@nestjs/common';
import { AuditService } from './audit.service';

/**
 * Audit Module
 * Provides audit trail functionality across the application
 */
@Module({
  providers: [AuditService],
  exports: [AuditService],
})
export class AuditModule {}
