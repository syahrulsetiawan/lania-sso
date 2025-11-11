import { Injectable } from '@nestjs/common';
import { PrismaService } from '../prisma/prisma.service';
import { FastifyRequest } from 'fastify';

/**
 * Audit Service
 * Handles comprehensive audit trail logging for all system operations
 */
@Injectable()
export class AuditService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Create audit log entry
   * @param data - Audit log data
   */
  async log(data: {
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
  }) {
    return this.prisma.auditLog.create({
      data: {
        id: this.generateId(),
        userType: data.userType,
        userId: data.userId,
        event: data.event,
        auditableTable: data.auditableTable,
        auditableId: data.auditableId,
        oldValues: data.oldValues ? JSON.stringify(data.oldValues) : null,
        newValues: data.newValues ? JSON.stringify(data.newValues) : null,
        url: data.url,
        payload: data.payload || null,
        ipAddress: data.ipAddress,
        userAgent: data.userAgent,
        tags: data.tags || null,
      },
    });
  }

  /**
   * Create audit log from FastifyRequest
   * @param request - Fastify request object
   * @param data - Additional audit data
   */
  async logFromRequest(
    request: FastifyRequest,
    data: {
      userType: string;
      userId: string;
      event: string;
      auditableTable: string;
      auditableId: string;
      oldValues?: any;
      newValues?: any;
      tags?: string;
    },
  ) {
    return this.log({
      userType: data.userType,
      userId: data.userId,
      event: data.event,
      auditableTable: data.auditableTable,
      auditableId: data.auditableId,
      oldValues: data.oldValues,
      newValues: data.newValues,
      url: request.url,
      payload: request.body as any,
      ipAddress: this.getClientIp(request),
      userAgent: request.headers['user-agent'] || 'Unknown',
      tags: data.tags,
    });
  }

  /**
   * Log user creation
   */
  async logUserCreated(
    request: FastifyRequest,
    userId: string,
    userData: any,
    createdBy: string,
  ) {
    return this.logFromRequest(request, {
      userType: 'Admin',
      userId: createdBy,
      event: 'created',
      auditableTable: 'users',
      auditableId: userId,
      newValues: userData,
      tags: 'user,created',
    });
  }

  /**
   * Log user update
   */
  async logUserUpdated(
    request: FastifyRequest,
    userId: string,
    oldData: any,
    newData: any,
    updatedBy: string,
  ) {
    return this.logFromRequest(request, {
      userType: 'Admin',
      userId: updatedBy,
      event: 'updated',
      auditableTable: 'users',
      auditableId: userId,
      oldValues: oldData,
      newValues: newData,
      tags: 'user,updated',
    });
  }

  /**
   * Log user deletion
   */
  async logUserDeleted(
    request: FastifyRequest,
    userId: string,
    userData: any,
    deletedBy: string,
  ) {
    return this.logFromRequest(request, {
      userType: 'Admin',
      userId: deletedBy,
      event: 'deleted',
      auditableTable: 'users',
      auditableId: userId,
      oldValues: userData,
      tags: 'user,deleted',
    });
  }

  /**
   * Log user login
   */
  async logUserLogin(request: FastifyRequest, userId: string) {
    return this.logFromRequest(request, {
      userType: 'User',
      userId: userId,
      event: 'login',
      auditableTable: 'sessions',
      auditableId: userId,
      tags: 'auth,login',
    });
  }

  /**
   * Log user logout
   */
  async logUserLogout(request: FastifyRequest, userId: string) {
    return this.logFromRequest(request, {
      userType: 'User',
      userId: userId,
      event: 'logout',
      auditableTable: 'sessions',
      auditableId: userId,
      tags: 'auth,logout',
    });
  }

  /**
   * Log failed login attempt
   */
  async logFailedLogin(request: FastifyRequest, email: string) {
    return this.logFromRequest(request, {
      userType: 'System',
      userId: email,
      event: 'login_failed',
      auditableTable: 'users',
      auditableId: 'unknown',
      tags: 'auth,login_failed,security',
    });
  }

  /**
   * Log password change
   */
  async logPasswordChange(request: FastifyRequest, userId: string) {
    return this.logFromRequest(request, {
      userType: 'User',
      userId: userId,
      event: 'password_changed',
      auditableTable: 'users',
      auditableId: userId,
      tags: 'security,password',
    });
  }

  /**
   * Get audit logs with filters
   */
  async getAuditLogs(params: {
    userId?: string;
    auditableTable?: string;
    event?: string;
    startDate?: Date;
    endDate?: Date;
    tags?: string;
    skip?: number;
    take?: number;
  }) {
    const { skip = 0, take = 50, ...filters } = params;

    const where: any = {};

    if (filters.userId) {
      where.userId = filters.userId;
    }

    if (filters.auditableTable) {
      where.auditableTable = filters.auditableTable;
    }

    if (filters.event) {
      where.event = filters.event;
    }

    if (filters.tags) {
      where.tags = { contains: filters.tags };
    }

    if (filters.startDate || filters.endDate) {
      where.createdAt = {};
      if (filters.startDate) {
        where.createdAt.gte = filters.startDate;
      }
      if (filters.endDate) {
        where.createdAt.lte = filters.endDate;
      }
    }

    const [logs, total] = await Promise.all([
      this.prisma.auditLog.findMany({
        where,
        skip,
        take,
        orderBy: { createdAt: 'desc' },
      }),
      this.prisma.auditLog.count({ where }),
    ]);

    return {
      data: logs,
      total,
      page: Math.floor(skip / take) + 1,
      pageSize: take,
      totalPages: Math.ceil(total / take),
    };
  }

  /**
   * Get audit log by ID
   */
  async getAuditLogById(id: string) {
    return this.prisma.auditLog.findUnique({
      where: { id },
    });
  }

  /**
   * Get recent audit logs
   */
  async getRecentLogs(limit: number = 100) {
    return this.prisma.auditLog.findMany({
      take: limit,
      orderBy: { createdAt: 'desc' },
    });
  }

  /**
   * Get audit statistics
   */
  async getAuditStats(startDate?: Date, endDate?: Date) {
    const where: any = {};

    if (startDate || endDate) {
      where.createdAt = {};
      if (startDate) where.createdAt.gte = startDate;
      if (endDate) where.createdAt.lte = endDate;
    }

    const [totalEvents, eventsByType, eventsByTable] = await Promise.all([
      this.prisma.auditLog.count({ where }),
      this.prisma.auditLog.groupBy({
        by: ['event'],
        _count: true,
        where,
      }),
      this.prisma.auditLog.groupBy({
        by: ['auditableTable'],
        _count: true,
        where,
      }),
    ]);

    return {
      totalEvents,
      eventsByType,
      eventsByTable,
    };
  }

  /**
   * Delete old audit logs
   */
  async cleanupOldLogs(retentionDays: number = 90) {
    const cutoffDate = new Date();
    cutoffDate.setDate(cutoffDate.getDate() - retentionDays);

    const result = await this.prisma.auditLog.deleteMany({
      where: {
        createdAt: { lt: cutoffDate },
      },
    });

    return {
      deletedCount: result.count,
      cutoffDate,
    };
  }

  /**
   * Helper: Generate UUID v4
   */
  private generateId(): string {
    return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, (c) => {
      const r = (Math.random() * 16) | 0;
      const v = c === 'x' ? r : (r & 0x3) | 0x8;
      return v.toString(16);
    });
  }

  /**
   * Helper: Extract client IP from request
   */
  private getClientIp(request: FastifyRequest): string {
    const forwarded = request.headers['x-forwarded-for'];
    if (forwarded) {
      const ips = Array.isArray(forwarded) ? forwarded[0] : forwarded;
      return ips.split(',')[0].trim();
    }
    return request.ip || 'unknown';
  }
}
