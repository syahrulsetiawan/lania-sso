import {
  ExceptionFilter,
  Catch,
  ArgumentsHost,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { FastifyReply, FastifyRequest } from 'fastify';
import { formatInTimeZone } from 'date-fns-tz';

/**
 * Global exception filter to catch all HttpException
 * and transform error output to standard JSON format with WIB timestamp
 */
@Catch(HttpException)
export class HttpExceptionFilter implements ExceptionFilter {
  catch(exception: HttpException, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<FastifyReply>();
    const request = ctx.getRequest<FastifyRequest>();

    const status = exception.getStatus
      ? exception.getStatus()
      : HttpStatus.INTERNAL_SERVER_ERROR;

    const exceptionResponse = exception.getResponse();
    let message = 'Internal server error';
    let reason = undefined;

    if (typeof exceptionResponse === 'string') {
      message = exceptionResponse;
    } else if (
      typeof exceptionResponse === 'object' &&
      exceptionResponse !== null
    ) {
      const res = exceptionResponse as Record<string, any>;
      message = res.message || message;
      reason = res.reason;
    }

    const timestampWIB = formatInTimeZone(
      new Date(),
      'Asia/Jakarta',
      "yyyy-MM-dd'T'HH:mm:ssXXX",
    );

    response.status(status).send({
      success: false,
      statusCode: status,
      message,
      reason,
      path: request.url,
      timestamp: timestampWIB,
    });
  }
}
