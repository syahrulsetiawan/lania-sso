import { Injectable, Logger } from '@nestjs/common';
import { PrismaService } from '../../prisma/prisma.service';

/**
 * Tenant RLS Service
 * Manages Row Level Security context for tenant data isolation
 */
@Injectable()
export class TenantRlsService {
  private readonly logger = new Logger(TenantRlsService.name);

  constructor(private readonly prisma: PrismaService) {}

  /**
   * Set tenant context for current database session
   * This enables RLS policies to filter data by tenant
   */
  async setTenantContext(tenantId: string): Promise<void> {
    if (!tenantId) {
      this.logger.warn('Attempted to set empty tenant context');
      return;
    }

    try {
      this.logger.debug(`Setting RLS context for tenant: ${tenantId}`);
      const query = `SET app.current_tenant_id = '${tenantId}'`;
      await this.prisma.$executeRawUnsafe(query);
      // await this.prisma.$executeRaw`SET app.current_tenant_id = ${tenantId}`;

      this.logger.debug(`✅ RLS context set for tenant: ${tenantId}`);
    } catch (error) {
      this.logger.error(
        `❌ Failed to set RLS context for tenant ${tenantId}:`,
        error,
      );
      throw error;
    }
  }

  /**
   * Clear tenant context from current database session
   */
  async clearTenantContext(): Promise<void> {
    try {
      await this.prisma.$executeRaw`RESET app.current_tenant_id`;

      this.logger.debug('🔄 RLS context cleared');
    } catch (error) {
      this.logger.warn('Failed to clear RLS context:', error);
      // Don't throw error for cleanup operations
    }
  }

  /**
   * Get current tenant context from database session
   */
  async getCurrentTenantContext(): Promise<string | null> {
    try {
      const result = await this.prisma.$queryRaw<[{ current_setting: string }]>`
        SELECT current_setting('app.current_tenant_id', true) as current_setting;
      `;

      const tenantId = result[0]?.current_setting;
      return tenantId && tenantId !== '' ? tenantId : null;
    } catch (error) {
      this.logger.warn('Failed to get current tenant context:', error);
      return null;
    }
  }

  /**
   * Execute queries with specific tenant context
   * Useful for admin operations or cross-tenant queries
   */
  async executeWithTenantContext<T>(
    tenantId: string,
    operation: () => Promise<T>,
  ): Promise<T> {
    const originalContext = await this.getCurrentTenantContext();

    try {
      await this.setTenantContext(tenantId);
      return await operation();
    } finally {
      if (originalContext) {
        await this.setTenantContext(originalContext);
      } else {
        await this.clearTenantContext();
      }
    }
  }

  /**
   * Execute queries without tenant context (bypass RLS)
   * Use only for admin operations or global queries
   */
  async executeWithoutTenantContext<T>(
    operation: () => Promise<T>,
  ): Promise<T> {
    const originalContext = await this.getCurrentTenantContext();

    try {
      await this.clearTenantContext();
      return await operation();
    } finally {
      if (originalContext) {
        await this.setTenantContext(originalContext);
      }
    }
  }

  /**
   * Verify RLS is working by testing tenant isolation
   * Returns true if RLS is properly filtering data
   */
  async verifyRlsIsolation(testTenantId: string): Promise<boolean> {
    try {
      // Set context to a specific tenant
      await this.setTenantContext(testTenantId);

      // Query tenant configs - should only return data for the set tenant
      const configs = await this.prisma.tenantConfig.findMany();

      // Check if all returned configs belong to the set tenant
      const allBelongToTenant = configs.every(
        (config) => config.tenantId === testTenantId,
      );

      this.logger.debug(
        `RLS verification for tenant ${testTenantId}: ${allBelongToTenant ? 'PASSED' : 'FAILED'}`,
      );

      return allBelongToTenant;
    } catch (error) {
      this.logger.error('RLS verification failed:', error);
      return false;
    }
  }
}
