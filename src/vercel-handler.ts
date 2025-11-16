import { Logger } from '@nestjs/common';
import { NestFastifyApplication } from '@nestjs/platform-fastify';
import { VercelRequest, VercelResponse } from '@vercel/node';
import { createApp } from './bootstrap';

let appPromise: Promise<NestFastifyApplication> | null = null;

async function getApplication(): Promise<NestFastifyApplication> {
  if (!appPromise) {
    const logger = new Logger('VercelHandler');
    appPromise = createApp().catch((error) => {
      logger.error('Failed to initialize NestJS application', error);
      appPromise = null;
      throw error;
    });
  }

  return appPromise;
}

export default async function handler(req: VercelRequest, res: VercelResponse) {
  try {
    const app = await getApplication();

    // Convert Vercel request to Fastify-compatible format
    const fastifyInstance = app.getHttpAdapter().getInstance();

    // Use Fastify's inject method for serverless
    const response = await fastifyInstance.inject({
      method: req.method as any,
      url: req.url || '/',
      headers: req.headers as any,
      payload: req.body,
      query: req.query as any,
    });

    // Set response headers
    Object.keys(response.headers).forEach((key) => {
      res.setHeader(key, response.headers[key] as string);
    });

    // Send response
    res.status(response.statusCode).send(response.payload);
  } catch (error) {
    const logger = new Logger('VercelHandler');
    logger.error('Handler error:', error);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: error instanceof Error ? error.message : 'Unknown error',
    });
  }
}
