import { WinstonModule } from 'nest-winston';
import * as winston from 'winston';
import * as DailyRotateFile from 'winston-daily-rotate-file';

/**
 * DICE Unified Logging Configuration
 * Implements structured JSON logging with correlation IDs, security events,
 * and performance metrics as per DICE Unified Logging Plan
 */

// Custom log format that matches DICE logging schema
const diceLogFormat = winston.format.printf(({ timestamp, level, message, meta, ...rest }: any) => {
  const logEntry = {
    timestamp,
    level,
    service: 'backend-api',
    correlationId: meta?.correlationId || rest.correlationId || 'system',
    sessionId: meta?.sessionId || rest.sessionId,
    userId: meta?.userId || rest.userId || 'anonymous',
    component: meta?.component || rest.component || 'unknown',
    action: meta?.action || rest.action,
    message,
    metadata: {
      ...meta?.metadata,
      ...rest.metadata,
      // Extract performance metrics
      duration: meta?.duration || rest.duration,
      statusCode: meta?.statusCode || rest.statusCode,
      ip: meta?.ip || rest.ip,
      userAgent: meta?.userAgent || rest.userAgent,
      requestSize: meta?.requestSize || rest.requestSize,
      responseSize: meta?.responseSize || rest.responseSize
    },
    tags: meta?.tags || rest.tags || [],
    // Security event enhancement
    securityEvent: meta?.securityEvent || rest.securityEvent,
    owaspCategory: meta?.owaspCategory || rest.owaspCategory,
    // Remove sensitive data
    ...Object.keys(rest).reduce((acc, key) => {
      if (!['password', 'token', 'secret', 'key', 'authorization'].some(sensitive => 
        key.toLowerCase().includes(sensitive))) {
        acc[key] = rest[key];
      }
      return acc;
    }, {} as any)
  };

  // Remove undefined/null values to keep logs clean
  Object.keys(logEntry).forEach(key => {
    if (logEntry[key] === undefined || logEntry[key] === null) {
      delete logEntry[key];
    }
  });

  return JSON.stringify(logEntry);
});

// Environment-specific log level
const getLogLevel = (): string => {
  const level = process.env.LOG_LEVEL || 'info';
  const environment = process.env.NODE_ENV || 'development';
  
  if (environment === 'production') {
    return ['error', 'warn', 'info'].includes(level) ? level : 'info';
  } else if (environment === 'test') {
    return 'error';
  }
  return level;
};

// Determine log directory based on environment
const getLogDirectory = (): string => {
  if (process.env.NODE_ENV === 'production') {
    return '/var/log/dice';
  } else if (process.env.DOCKER_CONTAINER === 'true') {
    return '/var/log/dice';
  }
  return './logs';
};

const logDirectory = getLogDirectory();

// Base transport configuration
const baseTransportConfig = {
  format: winston.format.combine(
    winston.format.timestamp({
      format: 'YYYY-MM-DDTHH:mm:ss.SSSZ'
    }),
    winston.format.errors({ stack: true }),
    diceLogFormat
  ),
  handleExceptions: true,
  handleRejections: true
};

// Console transport for development
const consoleTransport = new winston.transports.Console({
  ...baseTransportConfig,
  format: winston.format.combine(
    winston.format.timestamp({
      format: 'YYYY-MM-DDTHH:mm:ss.SSSZ'
    }),
    winston.format.errors({ stack: true }),
    winston.format.colorize(),
    winston.format.printf(({ timestamp, level, message, meta }: any) => {
      const correlationId = meta?.correlationId || 'system';
      const component = meta?.component || 'unknown';
      return `${timestamp} [${level}] [${correlationId}] ${component}: ${message}`;
    })
  )
});

// File transport for combined logs
const combinedFileTransport = new DailyRotateFile({
  ...baseTransportConfig,
  filename: `${logDirectory}/backend-combined-%DATE%.log`,
  datePattern: 'YYYY-MM-DD',
  maxFiles: '14d',
  maxSize: '100m',
  zippedArchive: true,
  auditFile: `${logDirectory}/combined-audit.json`
});

// File transport for error logs only
const errorFileTransport = new DailyRotateFile({
  ...baseTransportConfig,
  filename: `${logDirectory}/backend-error-%DATE%.log`,
  datePattern: 'YYYY-MM-DD',
  level: 'error',
  maxFiles: '30d',
  maxSize: '50m',
  zippedArchive: true,
  auditFile: `${logDirectory}/error-audit.json`
});

// File transport for security events
const securityFileTransport = new DailyRotateFile({
  ...baseTransportConfig,
  filename: `${logDirectory}/backend-security-%DATE%.log`,
  datePattern: 'YYYY-MM-DD',
  maxFiles: '90d',
  maxSize: '50m',
  zippedArchive: true,
  auditFile: `${logDirectory}/security-audit.json`,
  format: winston.format.combine(
    winston.format.timestamp({
      format: 'YYYY-MM-DDTHH:mm:ss.SSSZ'
    }),
    winston.format.errors({ stack: true }),
    winston.format((info: any) => {
      // Only log security events
      return info.meta?.securityEvent || info.securityEvent ? info : false;
    })(),
    diceLogFormat
  )
});

// File transport for performance logs
const performanceFileTransport = new DailyRotateFile({
  ...baseTransportConfig,
  filename: `${logDirectory}/backend-performance-%DATE%.log`,
  datePattern: 'YYYY-MM-DD',
  maxFiles: '7d',
  maxSize: '100m',
  zippedArchive: true,
  auditFile: `${logDirectory}/performance-audit.json`,
  format: winston.format.combine(
    winston.format.timestamp({
      format: 'YYYY-MM-DDTHH:mm:ss.SSSZ'
    }),
    winston.format.errors({ stack: true }),
    winston.format((info: any) => {
      // Only log performance-related entries
      const hasPerformanceData = info.meta?.duration || info.duration || 
                                 info.meta?.statusCode || info.statusCode ||
                                 info.meta?.responseTime || info.responseTime;
      return hasPerformanceData ? info : false;
    })(),
    diceLogFormat
  )
});

// Fluent Bit transport for ELK stack integration
const fluentBitTransport = new winston.transports.Http({
  host: process.env.FLUENT_BIT_HOST || 'localhost',
  port: parseInt(process.env.FLUENT_BIT_PORT || '24225'),
  path: '/dice.backend',
  format: winston.format.combine(
    winston.format.timestamp({
      format: 'YYYY-MM-DDTHH:mm:ss.SSSZ'
    }),
    winston.format.json()
  )
});

// Create logger configuration
export const createLoggerConfig = () => {
  const transports: winston.transport[] = [];

  // Always include file transports
  transports.push(combinedFileTransport, errorFileTransport, securityFileTransport, performanceFileTransport);

  // Add console transport for development
  if (process.env.NODE_ENV !== 'production') {
    transports.push(consoleTransport);
  }

  // Add Fluent Bit transport if enabled
  if (process.env.ENABLE_FLUENT_BIT === 'true') {
    transports.push(fluentBitTransport);
  }

  return WinstonModule.createLogger({
    level: getLogLevel(),
    format: winston.format.combine(
      winston.format.timestamp({
        format: 'YYYY-MM-DDTHH:mm:ss.SSSZ'
      }),
      winston.format.errors({ stack: true }),
      winston.format.metadata({
        fillExcept: ['message', 'level', 'timestamp', 'label']
      })
    ),
    transports,
    exitOnError: false,
    silent: process.env.NODE_ENV === 'test' && process.env.ENABLE_TEST_LOGGING !== 'true'
  });
};

// Export the configured logger
export const loggerConfig = createLoggerConfig();

// Export logger instance for direct use
export const logger = winston.createLogger({
  level: getLogLevel(),
  format: winston.format.combine(
    winston.format.timestamp({
      format: 'YYYY-MM-DDTHH:mm:ss.SSSZ'
    }),
    winston.format.errors({ stack: true }),
    diceLogFormat
  ),
  transports: [
    combinedFileTransport,
    errorFileTransport,
    securityFileTransport,
    performanceFileTransport,
    ...(process.env.NODE_ENV !== 'production' ? [consoleTransport] : [])
  ],
  exitOnError: false
});

// Helper functions for structured logging
export const createLogContext = (
  correlationId: string,
  sessionId?: string,
  userId?: string,
  component?: string
) => ({
  correlationId,
  sessionId,
  userId,
  component
});

export const createSecurityLogContext = (
  correlationId: string,
  securityEvent: any,
  owaspCategory?: string,
  sessionId?: string,
  userId?: string
) => ({
  correlationId,
  sessionId,
  userId,
  component: 'SecurityInterceptor',
  securityEvent,
  owaspCategory,
  tags: ['security', 'audit']
});

export const createPerformanceLogContext = (
  correlationId: string,
  duration: number,
  statusCode?: number,
  component?: string,
  action?: string
) => ({
  correlationId,
  component,
  action,
  metadata: {
    duration,
    statusCode
  },
  tags: ['performance', 'metrics']
}); 