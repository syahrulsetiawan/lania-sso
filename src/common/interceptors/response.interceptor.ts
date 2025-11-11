import {
  Injectable,
  NestInterceptor,
  ExecutionContext,
  CallHandler,
} from '@nestjs/common';
import { Observable } from 'rxjs';
import { map } from 'rxjs/operators';
import { formatInTimeZone } from 'date-fns-tz';

const TIMEZONE_WIB = 'Asia/Jakarta';
const DATE_FORMAT = "yyyy-MM-dd'T'HH:mm:ssXXX";

/**
 * Recursively converts all Date objects to WIB timezone string
 * @param data - The data to process (can be object, array, or primitive)
 * @returns The data with all Date objects converted to WIB string
 */
const convertDatesToLocalString = (data: any): any => {
  if (data === null || typeof data !== 'object') {
    return data;
  }

  if (data instanceof Date) {
    return formatInTimeZone(data, TIMEZONE_WIB, DATE_FORMAT);
  }

  if (Array.isArray(data)) {
    return data.map((item) => convertDatesToLocalString(item));
  }

  const newObject = {};
  for (const key in data) {
    if (Object.prototype.hasOwnProperty.call(data, key)) {
      newObject[key] = convertDatesToLocalString(data[key]);
    }
  }
  return newObject;
};

/**
 * Response interceptor to standardize all API responses
 * Converts all Date objects to WIB timezone strings
 */
@Injectable()
export class ResponseInterceptor implements NestInterceptor {
  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    return next.handle().pipe(
      map((data) => ({
        success: true,
        data: convertDatesToLocalString(data),
        timestamp: formatInTimeZone(new Date(), TIMEZONE_WIB, DATE_FORMAT),
      })),
    );
  }
}
