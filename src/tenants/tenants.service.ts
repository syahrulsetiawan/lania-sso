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
 * Handles tenant configuration and management
 */
@Injectable()
export class TenantsService {
  private readonly logger = new Logger(TenantsService.name);

  // Allowed tenant config keys
  private readonly ALLOWED_CONFIG_KEYS = [
    'accounting_fiscal_year_start',
    'auto_generate_invoice_payment',
    'auto_generate_invoice_receipt',
    'available_vat',
    'currency_format',
    'date_format',
    'default_language',
    'default_vat_percentage',
    'enable_minimum_margin',
    'generate_invoice_payment_by',
    'generate_invoice_receipt_by',
    'item_auto_generate_code',
    'main_currency',
    'margin_percentage',
    'minimum_stock_alert',
    'timezone',
  ];

  // Mapping from DTO keys to tenant table fields
  private readonly TENANT_FIELD_MAPPING = {
    company_name: 'name',
    company_address: 'address',
    company_photo: 'logoPath',
    company_phone: 'infoPhone',
    company_email: 'infoEmail',
    company_website: 'infoWebsite',
    company_tax_number: 'infoTaxNumber',
    company_country: 'country',
    company_province: 'province',
    company_city: 'city',
    company_postal_code: 'postalCode',
  };

  // Mapping from DTO config keys to tenant_configs keys
  private readonly CONFIG_KEY_MAPPING = {
    config_date_format: 'date_format',
    config_currency_format: 'currency_format',
    config_timezone: 'timezone',
    config_currency_code: 'main_currency',
    config_default_language: 'default_language',
    config_accounting_fiscal_year_start: 'accounting_fiscal_year_start',
    config_available_vat: 'available_vat',
    config_vat_percentage: 'default_vat_percentage',
  };

  constructor(
    private readonly prisma: PrismaService,
    private readonly auditService: AuditService,
  ) {}

  /**
   * Get tenant configuration
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

      // Get tenant data
      const tenant = await this.prisma.tenant.findUnique({
        where: { id: tenantId },
        select: {
          name: true,
          address: true,
          logoPath: true,
          infoPhone: true,
          infoEmail: true,
          infoWebsite: true,
          infoTaxNumber: true,
          country: true,
          province: true,
          city: true,
          postalCode: true,
        },
      });

      if (!tenant) {
        throw new NotFoundException({
          message: 'Tenant not found',
          reason: 'tenant_not_found',
        });
      }

      // Get tenant configs
      const configs = await this.prisma.tenantConfig.findMany({
        where: { tenantId },
        select: {
          configKey: true,
          configValue: true,
        },
      });

      // Default config values
      const defaultConfigs = {
        date_format: 'DD/MM/YYYY',
        currency_format: '#,###',
        timezone: 'WIB',
        main_currency: 'IDR',
        default_language: 'id',
        accounting_fiscal_year_start: '2025-01',
        available_vat: 'true',
        default_vat_percentage: '11',
      };

      // Merge configs with defaults
      const configMap = { ...defaultConfigs };
      configs.forEach((config) => {
        if (this.ALLOWED_CONFIG_KEYS.includes(config.configKey)) {
          configMap[config.configKey] = config.configValue || '';
        }
      });

      // Build response
      return {
        company_name: tenant.name || '',
        company_address: tenant.address || '',
        company_photo: tenant.logoPath || undefined,
        company_phone: tenant.infoPhone || '',
        company_email: tenant.infoEmail || '',
        company_website: tenant.infoWebsite || '',
        company_tax_number: tenant.infoTaxNumber || '',
        company_country: tenant.country || '',
        company_province: tenant.province || '',
        company_city: tenant.city || '',
        company_postal_code: tenant.postalCode || '',
        config_date_format: configMap.date_format,
        config_currency_format: configMap.currency_format,
        config_timezone: configMap.timezone,
        config_currency_code: configMap.main_currency,
        config_default_language: configMap.default_language,
        config_accounting_fiscal_year_start:
          configMap.accounting_fiscal_year_start,
        config_available_vat:
          configMap.available_vat === 'true' || configMap.available_vat === '1',
        config_vat_percentage:
          parseFloat(configMap.default_vat_percentage) || 11,
      };
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

      // Separate tenant fields and config fields
      const tenantUpdateData: any = {};
      const configUpdates: Array<{ key: string; value: string }> = [];

      Object.entries(configDto).forEach(([dtoKey, value]) => {
        if (value === undefined) return;

        // Check if it's a tenant field
        if (this.TENANT_FIELD_MAPPING[dtoKey]) {
          const dbField = this.TENANT_FIELD_MAPPING[dtoKey];
          tenantUpdateData[dbField] = value;
        }
        // Check if it's a config field
        else if (this.CONFIG_KEY_MAPPING[dtoKey]) {
          const configKey = this.CONFIG_KEY_MAPPING[dtoKey];
          if (this.ALLOWED_CONFIG_KEYS.includes(configKey)) {
            configUpdates.push({
              key: configKey,
              value: String(value),
            });
          }
        }
      });

      // Update tenant table if there are changes
      if (Object.keys(tenantUpdateData).length > 0) {
        await this.prisma.tenant.update({
          where: { id: tenantId },
          data: {
            ...tenantUpdateData,
            updatedAt: new Date(),
          },
        });
      }

      // Update tenant configs
      for (const { key, value } of configUpdates) {
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
              configValue: value,
              updatedAt: new Date(),
            },
          });
        } else {
          await this.prisma.tenantConfig.create({
            data: {
              id: uuidv4(),
              tenantId,
              configKey: key,
              configValue: value,
              configType: 'string',
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
