import { SetMetadata } from '@nestjs/common';

/**
 * Audit Table Decorator
 * Sets the auditable table name for audit logging
 *
 * @param tableName - Name of the table being audited
 *
 * @example
 * ```typescript
 * @Controller('users')
 * @AuditTable('users')
 * export class UserController {
 *   // All routes will log to 'users' table
 * }
 * ```
 */
export const AuditTable = (tableName: string) =>
  SetMetadata('audit:table', tableName);

/**
 * Audit Event Decorator
 * Sets the event name for audit logging
 *
 * @param eventName - Name of the event
 *
 * @example
 * ```typescript
 * @Post()
 * @AuditEvent('user_registered')
 * async register() {
 *   // Will log event as 'user_registered'
 * }
 * ```
 */
export const AuditEvent = (eventName: string) =>
  SetMetadata('audit:event', eventName);
