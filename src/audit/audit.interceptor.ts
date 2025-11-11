import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { tap } from 'rxjs/operators';
import { FastifyRequest } from 'fastify';
import { AuditService } from './audit.service';

/**
 * Audit Interceptor
 * Automatically logs API requests to audit trail
 * Use @UseInterceptors(AuditInterceptor) on controllers or routes
 */
@Injectable()
export class AuditInterceptor implements NestInterceptor {
  constructor(private readonly auditService: AuditService) {}

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const request = context.switchToHttp().getRequest<FastifyRequest>();
    const handler = context.getHandler();
    const controller = context.getClass();

    // Skip if request doesn't have user (not authenticated)
    const user = (request as any).user;
    if (!user) {
      return next.handle();
    }

    // Get metadata if set via decorator
    const auditableTable =
      Reflect.getMetadata('audit:table', handler) ||
      Reflect.getMetadata('audit:table', controller) ||
      'unknown';

    const event =
      Reflect.getMetadata('audit:event', handler) ||
      this.inferEventFromMethod(request.method);

    return next.handle().pipe(
      tap({
        next: (response) => {
          // Log successful operation
          this.auditService
            .log({
              userType: user.type || 'User',
              userId: user.sub || user.id,
              event,
              auditableTable,
              auditableId: response?.id || 'bulk',
              url: request.url,
              payload: request.body as any,
              ipAddress: this.getClientIp(request),
              userAgent: request.headers['user-agent'] || 'Unknown',
              newValues: response,
            })
            .catch((err) => {
              console.error('Failed to create audit log:', err);
            });
        },
        error: (error) => {
          // Log failed operation
          this.auditService
            .log({
              userType: user.type || 'User',
              userId: user.sub || user.id,
              event: `${event}_failed`,
              auditableTable,
              auditableId: 'error',
              url: request.url,
              payload: request.body as any,
              ipAddress: this.getClientIp(request),
              userAgent: request.headers['user-agent'] || 'Unknown',
              tags: 'error,failed',
            })
            .catch((err) => {
              console.error('Failed to create audit log:', err);
            });
        },
      }),
    );
  }

  private inferEventFromMethod(method: string): string {
    const eventMap: Record<string, string> = {
      POST: 'created',
      PUT: 'updated',
      PATCH: 'updated',
      DELETE: 'deleted',
      GET: 'accessed',
    };
    return eventMap[method] || 'unknown';
  }

  private getClientIp(request: FastifyRequest): string {
    const forwarded = request.headers['x-forwarded-for'];
    if (forwarded) {
      const ips = Array.isArray(forwarded) ? forwarded[0] : forwarded;
      return ips.split(',')[0].trim();
    }
    return request.ip || 'unknown';
  }
}
