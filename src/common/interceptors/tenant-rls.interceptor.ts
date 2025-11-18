import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
  Logger,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { tap, finalize } from 'rxjs/operators';
import { TenantRlsService } from '../services/tenant-rls.service';

/**
 * Tenant RLS Interceptor
 * Automatically sets tenant context before controller execution
 * and optionally clears it after execution
 */
@Injectable()
export class TenantRlsInterceptor implements NestInterceptor {
  private readonly logger = new Logger(TenantRlsInterceptor.name);

  constructor(private readonly tenantRlsService: TenantRlsService) {}

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const request = context.switchToHttp().getRequest();
    const user = request.user;

    // Skip if no authenticated user or no tenant
    if (!user?.lastTenantId) {
      return next.handle();
    }

    const tenantId = user.lastTenantId;

    return new Observable((observer) => {
      // Set tenant context before execution
      this.tenantRlsService
        .setTenantContext(tenantId)
        .then(() => {
          // Execute the controller
          return next.handle().subscribe({
            next: (value) => observer.next(value),
            error: (error) => observer.error(error),
            complete: () => observer.complete(),
          });
        })
        .catch((error) => {
          this.logger.error(
            'Failed to set tenant context in interceptor:',
            error,
          );
          // Continue execution even if RLS fails
          return next.handle().subscribe({
            next: (value) => observer.next(value),
            error: (error) => observer.error(error),
            complete: () => observer.complete(),
          });
        });
    }).pipe(
      tap(() => {
        this.logger.debug(`Request processed with tenant context: ${tenantId}`);
      }),
      finalize(() => {
        // Optional: Clear context after request
        // Uncomment if you want to clear context after each request
        // this.tenantRlsService.clearTenantContext().catch(() => {});
      }),
    );
  }
}
