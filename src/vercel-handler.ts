import { Logger } from '@nestjs/common';
import { NestFastifyApplication } from '@nestjs/platform-fastify';
import { VercelRequest, VercelResponse } from '@vercel/node';
import { createApp } from './bootstrap';

let appPromise: Promise<NestFastifyApplication> | null = null;

async function getApplication(): Promise<NestFastifyApplication> {
  if (!appPromise) {
    const logger = new Logger('Bootstrap');
    appPromise = createApp().catch((error) => {
      logger.error('Failed to initialize NestJS application', error);
      appPromise = null;
      throw error;
    });
  }

  return appPromise;
}

export default async function handler(
  req: VercelRequest,
  res: VercelResponse,
) {
  const app = await getApplication();
  const fastifyInstance = app.getHttpAdapter().getInstance();

  // Fastify exposes the underlying Node HTTP server interface.
  fastifyInstance.server.emit('request', req, res);
}
