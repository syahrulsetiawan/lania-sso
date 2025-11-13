import {
  Controller,
  Get,
  Patch,
  Body,
  UseGuards,
  Req,
  HttpCode,
  HttpStatus,
} from '@nestjs/common';
import {
  ApiTags,
  ApiOperation,
  ApiResponse,
  ApiBearerAuth,
} from '@nestjs/swagger';
import { TenantsService } from './tenants.service';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';
import type { FastifyRequest } from 'fastify';
import { TenantConfigDto, TenantConfigResponseDto } from './dto';

/**
 * Tenants Controller
 * Handles tenant configuration endpoints
 *
 * Endpoints:
 * - GET /api/v1/tenants/config - Get tenant configuration
 * - PATCH /api/v1/tenants/config - Update tenant configuration
 */
@ApiTags('Tenants')
@Controller('tenants')
export class TenantsController {
  constructor(private readonly tenantsService: TenantsService) {}

  /**
   * GET /api/v1/tenants/config
   *
   * Get current tenant configuration
   * Returns tenant details and configuration settings
   * Requires authentication (JWT token in Authorization header)
   *
   * @param request - Fastify request object with user info
   * @returns Tenant configuration object
   */
  @Get('config')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Get tenant configuration',
    description:
      'Returns current tenant configuration including company details and settings',
  })
  @ApiResponse({
    status: 200,
    description: 'Tenant configuration retrieved successfully',
    type: TenantConfigResponseDto,
  })
  @ApiResponse({
    status: 401,
    description: 'Unauthorized - Invalid or missing token',
  })
  @ApiResponse({
    status: 404,
    description: 'Tenant not found or access denied',
  })
  @HttpCode(HttpStatus.OK)
  async getTenantConfig(@Req() request: any): Promise<TenantConfigResponseDto> {
    const userId = request.user.id;
    const tenantId = request.user.lastTenantId;
    return this.tenantsService.getTenantConfig(userId, tenantId);
  }

  /**
   * PATCH /api/v1/tenants/config
   *
   * Update current tenant configuration
   * Updates tenant details and configuration settings (partial update supported)
   * Requires authentication (JWT token in Authorization header)
   *
   * @param configDto - Tenant configuration to update
   * @param request - Fastify request object with user info
   * @returns Updated tenant configuration object
   */
  @Patch('config')
  @UseGuards(JwtAuthGuard)
  @ApiBearerAuth('JWT-auth')
  @ApiOperation({
    summary: 'Update tenant configuration',
    description:
      'Partially update tenant configuration including company details and settings. Only send the fields you want to update.',
  })
  @ApiResponse({
    status: 200,
    description: 'Tenant configuration updated successfully',
    type: TenantConfigResponseDto,
  })
  @ApiResponse({
    status: 400,
    description: 'Bad request - Invalid configuration data',
  })
  @ApiResponse({
    status: 401,
    description: 'Unauthorized - Invalid or missing token',
  })
  @ApiResponse({
    status: 404,
    description: 'Tenant not found or access denied',
  })
  @HttpCode(HttpStatus.OK)
  async updateTenantConfig(
    @Body() configDto: TenantConfigDto,
    @Req() request: any,
  ): Promise<TenantConfigResponseDto> {
    const userId = request.user.id;
    const tenantId = request.user.lastTenantId;
    return this.tenantsService.updateTenantConfig(
      userId,
      tenantId,
      configDto,
      request,
    );
  }
}
