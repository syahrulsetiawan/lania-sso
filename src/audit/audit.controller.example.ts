import {
  Controller,
  Get,
  Post,
  Put,
  Delete,
  Body,
  Param,
  Query,
  UseGuards,
  UseInterceptors,
  Request,
} from '@nestjs/common';
import {
  AuditService,
  AuditInterceptor,
  AuditTable,
  AuditEvent,
} from '../audit';
import { JwtAuthGuard } from '../common/guards/jwt-auth.guard';

/**
 * Example Controller demonstrating Audit Trail usage
 *
 * This controller shows:
 * 1. Automatic audit logging with interceptor
 * 2. Manual audit logging with service
 * 3. Custom event names
 * 4. Querying audit logs
 */
@Controller('audit')
export class AuditController {
  constructor(private readonly auditService: AuditService) {}

  /**
   * Get audit logs with filters
   * Example: GET /api/v1/audit?userId=123&event=login&skip=0&take=50
   */
  @Get()
  @UseGuards(JwtAuthGuard)
  async getAuditLogs(
    @Query('userId') userId?: string,
    @Query('auditableTable') auditableTable?: string,
    @Query('event') event?: string,
    @Query('tags') tags?: string,
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
    @Query('skip') skip?: string,
    @Query('take') take?: string,
  ) {
    return this.auditService.getAuditLogs({
      userId,
      auditableTable,
      event,
      tags,
      startDate: startDate ? new Date(startDate) : undefined,
      endDate: endDate ? new Date(endDate) : undefined,
      skip: skip ? parseInt(skip) : 0,
      take: take ? parseInt(take) : 50,
    });
  }

  /**
   * Get audit log by ID
   * Example: GET /api/v1/audit/123e4567-e89b-12d3-a456-426614174000
   */
  @Get(':id')
  @UseGuards(JwtAuthGuard)
  async getAuditLogById(@Param('id') id: string) {
    return this.auditService.getAuditLogById(id);
  }

  /**
   * Get recent audit logs
   * Example: GET /api/v1/audit/recent?limit=100
   */
  @Get('recent/logs')
  @UseGuards(JwtAuthGuard)
  async getRecentLogs(@Query('limit') limit?: string) {
    return this.auditService.getRecentLogs(limit ? parseInt(limit) : 100);
  }

  /**
   * Get audit statistics
   * Example: GET /api/v1/audit/stats?startDate=2024-01-01&endDate=2024-12-31
   */
  @Get('stats/summary')
  @UseGuards(JwtAuthGuard)
  async getAuditStats(
    @Query('startDate') startDate?: string,
    @Query('endDate') endDate?: string,
  ) {
    return this.auditService.getAuditStats(
      startDate ? new Date(startDate) : undefined,
      endDate ? new Date(endDate) : undefined,
    );
  }

  /**
   * Manual audit log creation (admin only)
   * Example: POST /api/v1/audit/manual
   */
  @Post('manual')
  @UseGuards(JwtAuthGuard)
  async createManualAuditLog(
    @Body()
    dto: {
      userType: string;
      userId: string;
      event: string;
      auditableTable: string;
      auditableId: string;
      oldValues?: any;
      newValues?: any;
      url: string;
      payload?: any;
      ipAddress: string;
      userAgent: string;
      tags?: string;
    },
  ) {
    return this.auditService.log(dto);
  }

  /**
   * Cleanup old audit logs (admin only)
   * Example: DELETE /api/v1/audit/cleanup?retentionDays=90
   */
  @Delete('cleanup')
  @UseGuards(JwtAuthGuard)
  async cleanupOldLogs(@Query('retentionDays') retentionDays?: string) {
    return this.auditService.cleanupOldLogs(
      retentionDays ? parseInt(retentionDays) : 90,
    );
  }
}

/**
 * Example User Controller with Audit Interceptor
 * Demonstrates automatic audit logging
 */
@Controller('example-users')
@UseGuards(JwtAuthGuard)
@UseInterceptors(AuditInterceptor)
@AuditTable('users') // All routes will log to 'users' table
export class ExampleUserWithAuditController {
  @Post()
  @AuditEvent('user_created') // Custom event name
  async createUser(@Body() dto: any) {
    // This will automatically log:
    // - event: 'user_created'
    // - auditableTable: 'users'
    // - newValues: response data
    return { id: '123', ...dto };
  }

  @Put(':id')
  async updateUser(@Param('id') id: string, @Body() dto: any) {
    // This will automatically log:
    // - event: 'updated' (inferred from PUT method)
    // - auditableTable: 'users'
    // - auditableId: from response.id
    return { id, ...dto };
  }

  @Delete(':id')
  @AuditEvent('user_deleted')
  async deleteUser(@Param('id') id: string) {
    // This will automatically log:
    // - event: 'user_deleted'
    // - auditableTable: 'users'
    return { id, deleted: true };
  }

  @Get(':id')
  async getUser(@Param('id') id: string) {
    // This will automatically log:
    // - event: 'accessed' (inferred from GET method)
    // - auditableTable: 'users'
    return { id, email: 'user@example.com' };
  }
}
