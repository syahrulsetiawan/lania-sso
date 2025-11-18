import {
  Injectable,
  OnModuleInit,
  OnModuleDestroy,
  Logger,
} from '@nestjs/common';
import { PrismaClient } from '@prisma/client';

/**
 * Prisma Service
 * Manages database connection lifecycle and provides PrismaClient instance
 */
@Injectable()
export class PrismaService
  extends PrismaClient
  implements OnModuleInit, OnModuleDestroy
{
  private readonly logger = new Logger(PrismaService.name);

  constructor() {
    super({
      log: [
        { emit: 'event', level: 'query' },
        { emit: 'event', level: 'error' },
        { emit: 'event', level: 'info' },
        { emit: 'event', level: 'warn' },
      ],
      errorFormat: 'pretty',
    });

    // Log queries in development
    if (process.env.NODE_ENV === 'development') {
      this.$on('query' as never, (e: any) => {
        this.logger.debug(`Query: ${e.query}`);
        this.logger.debug(`Duration: ${e.duration}ms`);
      });
    }

    // Log errors
    this.$on('error' as never, (e: any) => {
      this.logger.error('Prisma Error:', e);
    });

    // Log info
    this.$on('info' as never, (e: any) => {
      this.logger.log(e.message);
    });

    // Log warnings
    this.$on('warn' as never, (e: any) => {
      this.logger.warn(e.message);
    });
  }

  /**
   * Connect to database when module initializes
   */
  async onModuleInit() {
    try {
      await this.$connect();
      this.logger.log('✅ Database connected successfully');
    } catch (error) {
      this.logger.error('❌ Failed to connect to database', error);
      throw error;
    }
  }

  /**
   * Disconnect from database when module destroys
   */
  async onModuleDestroy() {
    try {
      await this.$disconnect();
      this.logger.log('Database disconnected');
    } catch (error) {
      this.logger.error('Error disconnecting from database', error);
    }
  }

  /**
   * Clean all tables (use only for testing!)
   */
  async cleanDatabase() {
    if (process.env.NODE_ENV === 'production') {
      throw new Error('Cannot clean database in production!');
    }

    const models = Reflect.ownKeys(this).filter(
      (key) =>
        key !== '_baseDmmf' &&
        typeof key === 'string' &&
        !key.startsWith('_') &&
        !key.startsWith('$'),
    );

    return Promise.all(
      models.map((modelKey) => {
        const model = this[modelKey as keyof this];
        if (model && typeof model === 'object' && 'deleteMany' in model) {
          return (model as any).deleteMany();
        }
        return Promise.resolve();
      }),
    );
  }

  /**
   * Set tenant context for RLS
   * @param tenantId - Tenant ID to set in context
   */
  async setTenantContext(tenantId: string): Promise<void> {
    await this.$executeRaw`SET app.current_tenant_id = ${tenantId};`;
  }

  /**
   * Clear tenant context for RLS
   */
  async clearTenantContext(): Promise<void> {
    await this.$executeRaw`RESET app.current_tenant_id;`;
  }

  /**
   * Get current tenant context
   */
  async getCurrentTenantContext(): Promise<string | null> {
    const result = await this.$queryRaw<[{ current_setting: string }]>`
      SELECT current_setting('app.current_tenant_id', true) as current_setting;
    `;

    const tenantId = result[0]?.current_setting;
    return tenantId && tenantId !== '' ? tenantId : null;
  }

  /**
   * Execute operation with specific tenant context
   */
  async withTenantContext<T>(
    tenantId: string,
    operation: () => Promise<T>,
  ): Promise<T> {
    const originalContext = await this.getCurrentTenantContext();

    try {
      await this.setTenantContext(tenantId);
      return await operation();
    } finally {
      if (originalContext) {
        await this.setTenantContext(originalContext);
      } else {
        await this.clearTenantContext();
      }
    }
  }

  /**
   * Enable soft delete for models
   * Add deletedAt field to your models to use this
   *
   * Note: Currently handled manually in queries with `where: { deletedAt: null }`
   * Uncomment if you want to use middleware approach
   */
  // enableSoftDelete() {
  //   this.$use(async (params, next) => {
  //     // Check if model exists
  //     if (!params.model) return next(params);

  //     if (params.action === 'delete') {
  //       // Convert delete to update with deletedAt
  //       params.action = 'update';
  //       params.args = params.args || {};
  //       params.args['data'] = { deletedAt: new Date() };
  //     }

  //     if (params.action === 'deleteMany') {
  //       // Convert deleteMany to updateMany with deletedAt
  //       params.action = 'updateMany';
  //       params.args = params.args || {};
  //       if (params.args.data !== undefined) {
  //         params.args.data['deletedAt'] = new Date();
  //       } else {
  //         params.args['data'] = { deletedAt: new Date() };
  //       }
  //     }

  //     return next(params);
  //   });
  // }
}
