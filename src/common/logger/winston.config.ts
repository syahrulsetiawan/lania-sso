import { format, createLogger, transports } from 'winston';
import DailyRotateFile from 'winston-daily-rotate-file';
import * as fs from 'fs';
import * as path from 'path';

const LOG_DIR = 'logs';
const { combine, timestamp, printf, colorize, errors } = format;

// Ensure logs directory exists
if (!fs.existsSync(LOG_DIR)) {
  fs.mkdirSync(LOG_DIR, { recursive: true });
}

/**
 * Custom log format for Winston
 * Example output: 2025-11-08 15:45:00 [Nest] DEBUG: Log message
 */
const logFormat = printf(({ level, message, timestamp, context }) => {
  return `${timestamp} [${context || 'Nest'}] ${level.toUpperCase()}: ${message}`;
});

/**
 * Format for console logs (with colors)
 */
const consoleFormat = combine(
  colorize({ all: true }),
  timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
  logFormat,
);

/**
 * Format for file logs (without colors)
 */
const fileFormat = combine(
  errors({ stack: true }),
  timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
  logFormat,
);

/**
 * Error transport - logs errors to separate file
 */
const errorTransport = new DailyRotateFile({
  level: 'error',
  filename: `${LOG_DIR}/%DATE%-error.log`,
  datePattern: 'YYYY-MM-DD',
  zippedArchive: true,
  maxSize: '20m',
  maxFiles: '14d',
  format: fileFormat,
});

/**
 * Combined transport - logs all levels to file
 */
const combinedTransport = new DailyRotateFile({
  filename: `${LOG_DIR}/%DATE%-combined.log`,
  datePattern: 'YYYY-MM-DD',
  zippedArchive: true,
  maxSize: '20m',
  maxFiles: '14d',
  format: fileFormat,
});

/**
 * Console transport - outputs to terminal
 */
const consoleTransport = new transports.Console({
  format: consoleFormat,
});

/**
 * Winston logger configuration with daily file rotation
 */
export const winstonLogger = createLogger({
  level: 'debug',
  transports: [consoleTransport, combinedTransport, errorTransport],
  exitOnError: false,
});
