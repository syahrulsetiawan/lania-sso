import { Injectable, NestMiddleware, Logger } from '@nestjs/common';
import { FastifyRequest, FastifyReply } from 'fastify';
import { PrismaService } from '../../prisma/prisma.service';

/**
 * Tenant Context Middleware
 * Sets RLS context based on authenticated user's current tenant
 */
@Injectable()
export class TenantContextMiddleware implements NestMiddleware {
  private readonly logger = new Logger(TenantContextMiddleware.name);

  constructor(private readonly prisma: PrismaService) {}

  async use(
    req: FastifyRequest & { user?: any },
    res: FastifyReply,
    next: () => void,
  ) {
    try {
      // Set RLS context if user is authenticated and has a tenant
      if (req.user?.lastTenantId) {
        await this.setTenantContext(req.user.lastTenantId);
        this.logger.debug(
          `RLS context set for tenant: ${req.user.lastTenantId}`,
        );
      }

      next();
    } catch (error) {
      this.logger.error('Failed to set tenant context:', error);
      // Continue execution even if RLS context fails
      // This prevents blocking requests when RLS is not critical
      next();
    }
  }

  /**
   * Set tenant context for RLS
   */
  private async setTenantContext(tenantId: string): Promise<void> {
    try {
      await this.prisma.$executeRaw`SET app.current_tenant_id = ${tenantId}`;
    } catch (error) {
      this.logger.warn(
        `Failed to set RLS context for tenant ${tenantId}:`,
        error,
      );
      throw error;
    }
  }

  /**
   * Clear tenant context (useful for cleanup)
   */
  static async clearTenantContext(prisma: PrismaService): Promise<void> {
    try {
      await prisma.$executeRaw`RESET app.current_tenant_id`;
    } catch (error) {
      // Ignore errors when clearing context
      console.warn('Failed to clear RLS context:', error);
    }
  }
}
