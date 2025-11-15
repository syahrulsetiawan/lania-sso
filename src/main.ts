import { Logger } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createApp } from './bootstrap';

async function bootstrap() {
  const logger = new Logger('Bootstrap');
  const app = await createApp();
  const configService = app.get(ConfigService);
  const port = configService.get<number>('PORT') || 3000;
  const host = configService.get<string>('HOST') || '0.0.0.0';

  await app.listen(port, host);

  logger.log(`dYs? Application is running on: http://${host}:${port}/api/v1`);
  logger.log(`dY"s Swagger docs available at: http://${host}:${port}/api/docs`);
  logger.log(
    `dY"? Environment: ${configService.get<string>('NODE_ENV') || 'development'}`,
  );
}

bootstrap().catch((err) => {
  const logger = new Logger('Bootstrap');
  logger.error('�?O Error starting application', err);
  process.exit(1);
});
