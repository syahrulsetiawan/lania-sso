import {
  Injectable,
  BadRequestException,
  Logger,
  NotFoundException,
} from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { AuditService } from '../audit/audit.service';
import type { FastifyRequest } from 'fastify';
import { TenantConfigDto, TenantConfigResponseDto } from './dto';
import { v4 as uuidv4 } from 'uuid';

/**
 * Tenants Service
 * Handles tenant configuration management based on core_tenant_configs
 */
@Injectable()
export class TenantsService {
  private readonly logger = new Logger(TenantsService.name);

  constructor(
    private readonly prisma: PrismaService,
    private readonly auditService: AuditService,
  ) {}

  /**
   * Get tenant configuration
   * Returns all configs defined in core_tenant_configs
   */
  async getTenantConfig(
    userId: string,
    tenantId: string,
  ): Promise<TenantConfigResponseDto> {
    try {
      // Verify user has access to tenant
      const tenantAccess = await this.prisma.tenantHasUser.findFirst({
        where: {
          userId,
          tenantId,
          isActive: true,
        },
      });

      if (!tenantAccess) {
        throw new NotFoundException({
          message: 'Tenant not found or access denied',
          reason: 'tenant_access_denied',
        });
      }

      // Get core configs to know what configs are available
      const coreConfigs = await this.prisma.coreTenantConfig.findMany({
        select: {
          key: true,
          defaultValue: true,
          configType: true,
        },
      });

      // Get tenant-specific configs
      const tenantConfigs = await this.prisma.tenantConfig.findMany({
        where: { tenantId },
        select: {
          configKey: true,
          configValue: true,
        },
      });

      // Build config map with defaults from core
      const configMap = new Map<string, any>();
      coreConfigs.forEach((coreConfig) => {
        configMap.set(coreConfig.key, coreConfig.defaultValue || '');
      });

      // Override with tenant-specific values
      tenantConfigs.forEach((config) => {
        configMap.set(config.configKey, config.configValue);
      });

      // Parse values based on type
      const response: TenantConfigResponseDto = {
        default_currency: configMap.get('default_currency') || 'USD',
        number_format:
          configMap.get('number_format') ||
          '{"thousands_separator": ",", "decimal_separator": "."}',
        number_decimal: parseInt(configMap.get('number_decimal') || '2', 10),
        enabled_multi_currency:
          configMap.get('enabled_multi_currency') === 'true',
        timezone: configMap.get('timezone') || 'UTC',
        date_format: configMap.get('date_format') || 'YYYY-MM-DD',
      };

      return response;
    } catch (error) {
      if (error instanceof NotFoundException) {
        throw error;
      }
      this.logger.error('Get tenant config error:', error);
      throw new BadRequestException(
        'An error occurred while fetching tenant configuration',
      );
    }
  }

  /**
   * Update tenant configuration
   * Only allows updating configs defined in core_tenant_configs
   */
  async updateTenantConfig(
    userId: string,
    tenantId: string,
    configDto: TenantConfigDto,
    request: FastifyRequest,
  ): Promise<TenantConfigResponseDto> {
    try {
      // Verify user has access to tenant
      const tenantAccess = await this.prisma.tenantHasUser.findFirst({
        where: {
          userId,
          tenantId,
          isActive: true,
        },
      });

      if (!tenantAccess) {
        throw new NotFoundException({
          message: 'Tenant not found or access denied',
          reason: 'tenant_access_denied',
        });
      }

      // Get valid config keys from core_tenant_configs
      const coreConfigs = await this.prisma.coreTenantConfig.findMany({
        select: { key: true, configType: true },
      });

      const validConfigKeys = new Set(coreConfigs.map((c) => c.key));
      const configTypeMap = new Map(
        coreConfigs.map((c) => [c.key, c.configType]),
      );

      // Process updates
      const updates = Object.entries(configDto).filter(
        ([, value]) => value !== undefined,
      );

      for (const [key, value] of updates) {
        // Validate config key exists in core
        if (!validConfigKeys.has(key)) {
          this.logger.warn(`Skipping invalid config key: ${key}`);
          continue;
        }

        const configType = configTypeMap.get(key);
        let configValue: string;

        // Convert value to string based on type
        if (configType === 'boolean') {
          configValue = String(Boolean(value));
        } else if (configType === 'integer') {
          configValue = String(Number(value));
        } else {
          configValue = String(value);
        }

        // Upsert tenant config
        const existingConfig = await this.prisma.tenantConfig.findFirst({
          where: {
            tenantId,
            configKey: key,
          },
        });

        if (existingConfig) {
          await this.prisma.tenantConfig.update({
            where: { id: existingConfig.id },
            data: {
              configValue,
              configType: configType || 'string',
              updatedAt: new Date(),
            },
          });
        } else {
          await this.prisma.tenantConfig.create({
            data: {
              id: uuidv4(),
              tenantId,
              configKey: key,
              configValue,
              configType: configType || 'string',
              createdAt: new Date(),
              updatedAt: new Date(),
            },
          });
        }
      }

      // Audit log
      await this.auditService.logFromRequest(request, {
        userType: 'User',
        userId,
        event: 'tenant_config_updated',
        auditableTable: 'tenants',
        auditableId: tenantId,
        newValues: configDto,
        tags: 'tenant,config,settings',
      });

      this.logger.log(
        `Tenant ${tenantId} configuration updated by user ${userId}`,
      );

      // Return updated config
      return this.getTenantConfig(userId, tenantId);
    } catch (error) {
      if (error instanceof NotFoundException) {
        throw error;
      }
      this.logger.error('Update tenant config error:', error);
      throw new BadRequestException(
        'An error occurred while updating tenant configuration',
      );
    }
  }
}
