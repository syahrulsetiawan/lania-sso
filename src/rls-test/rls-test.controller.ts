import { Controller, Get, UseGuards, Req, Logger } from '@nestjs/common';
import { FastifyRequest } from 'fastify';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import { TenantRlsService } from '../common/services/tenant-rls.service';
import { PrismaService } from '../prisma/prisma.service';

/**
 * RLS Test Controller
 * Provides endpoints to test and verify Row Level Security functionality
 */
@Controller('rls')
@UseGuards(JwtAuthGuard)
export class RlsTestController {
  private readonly logger = new Logger(RlsTestController.name);

  constructor(
    private readonly tenantRlsService: TenantRlsService,
    private readonly prisma: PrismaService,
  ) {}

  /**
   * Test RLS context - shows current tenant context and filtered data
   */
  @Get('test')
  async testRls(@Req() request: FastifyRequest & { user: any }) {
    const { user } = request;

    try {
      // Get current RLS context
      const currentContext =
        await this.tenantRlsService.getCurrentTenantContext();

      // Query tenant configs - should only show data for current tenant
      const tenantConfigs = await this.prisma.tenantConfig.findMany({
        take: 5, // Limit results for demo
      });

      // Query tenant licenses - should only show data for current tenant
      const tenantLicenses = await this.prisma.tenantLicense.findMany({
        take: 5,
      });

      return {
        message: 'RLS test successful',
        user: {
          id: user.id,
          name: user.name,
          lastTenantId: user.lastTenantId,
        },
        rls: {
          currentContext,
          isContextSet: currentContext === user.lastTenantId,
        },
        data: {
          tenantConfigs: tenantConfigs.map((config) => ({
            id: config.id,
            tenantId: config.tenantId,
            configKey: config.configKey,
            configValue: config.configValue,
          })),
          tenantLicenses: tenantLicenses.map((license) => ({
            id: license.id,
            tenantId: license.tenantId,
            licenseKey: license.licenseKey,
            licenseValue: license.licenseValue,
          })),
        },
        note: 'All data above should belong to the current tenant only',
      };
    } catch (error) {
      this.logger.error('RLS test failed:', error);
      return {
        message: 'RLS test failed',
        error: error.message,
      };
    }
  }

  /**
   * Verify RLS isolation - tests that RLS properly filters data
   */
  @Get('verify')
  async verifyRlsIsolation(@Req() request: FastifyRequest & { user: any }) {
    const { user } = request;

    try {
      const isIsolated = await this.tenantRlsService.verifyRlsIsolation(
        user.lastTenantId,
      );

      return {
        message: 'RLS verification completed',
        tenantId: user.lastTenantId,
        isProperlyIsolated: isIsolated,
        status: isIsolated ? 'PASS' : 'FAIL',
        note: isIsolated
          ? 'RLS is working correctly - data is properly isolated by tenant'
          : 'RLS verification failed - data leakage detected',
      };
    } catch (error) {
      this.logger.error('RLS verification failed:', error);
      return {
        message: 'RLS verification failed',
        error: error.message,
        status: 'ERROR',
      };
    }
  }

  /**
   * Test cross-tenant access (should fail with proper RLS)
   */
  @Get('cross-tenant-test')
  async testCrossTenantAccess(@Req() request: FastifyRequest & { user: any }) {
    const { user } = request;

    try {
      // Get all tenants first (this should work as tenants table doesn't have RLS)
      const allTenants = await this.prisma.tenant.findMany({
        select: { id: true, name: true },
        take: 5,
      });

      const testResults: any[] = [];

      // Test access to each tenant's data
      for (const tenant of allTenants) {
        try {
          // Set context to different tenant
          await this.tenantRlsService.setTenantContext(tenant.id);

          const configs = await this.prisma.tenantConfig.findMany({
            take: 1,
          });

          testResults.push({
            tenantId: tenant.id,
            tenantName: tenant.name,
            canAccess: configs.length > 0,
            configCount: configs.length,
          });
        } catch (error) {
          testResults.push({
            tenantId: tenant.id,
            tenantName: tenant.name,
            canAccess: false,
            error: error.message,
          });
        }
      }

      // Restore original context
      if (user.lastTenantId) {
        await this.tenantRlsService.setTenantContext(user.lastTenantId);
      }

      return {
        message: 'Cross-tenant access test completed',
        currentUser: {
          id: user.id,
          tenantId: user.lastTenantId,
        },
        testResults,
        note: 'Each tenant should only show data when context is set to that tenant',
      };
    } catch (error) {
      this.logger.error('Cross-tenant test failed:', error);
      return {
        message: 'Cross-tenant test failed',
        error: error.message,
      };
    }
  }
}
