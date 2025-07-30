import { Injectable, NestMiddleware, Logger } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';
import { v4 as uuidv4 } from 'uuid';

/**
 * DICE Correlation ID Middleware
 * Implements correlation ID tracking across distributed requests
 * as per DICE Unified Logging Plan
 */

// Extend Express Request type to include correlation metadata
declare global {
  namespace Express {
    interface Request {
      correlationId: string;
      sessionId?: string;
      userId?: string;
      requestStartTime: number;
      requestSize?: number;
    }
  }
}

@Injectable()
export class CorrelationMiddleware implements NestMiddleware {
  private readonly logger = new Logger(CorrelationMiddleware.name);

  use(req: Request, res: Response, next: NextFunction) {
    const startTime = Date.now();
    
    // Generate or extract correlation ID
    const correlationId = this.getOrGenerateCorrelationId(req);
    
    // Extract session and user information
    const sessionId = this.extractSessionId(req);
    const userId = this.extractUserId(req);
    
    // Calculate request size
    const requestSize = this.calculateRequestSize(req);
    
    // Attach metadata to request object
    req.correlationId = correlationId;
    req.sessionId = sessionId;
    req.userId = userId;
    req.requestStartTime = startTime;
    req.requestSize = requestSize;
    
    // Set response headers for traceability
    res.setHeader('x-correlation-id', correlationId);
    res.setHeader('x-request-id', correlationId); // Alternative header name
    
    if (sessionId) {
      res.setHeader('x-session-id', sessionId);
    }
    
    // Log request initiation
    this.logRequestStart(req, correlationId, sessionId, userId);
    
    // Capture response finish event for performance logging
    const originalSend = res.send;
    res.send = function(body: any) {
      const duration = Date.now() - startTime;
      const responseSize = Buffer.byteLength(body || '', 'utf8');
      
      // Set additional response headers
      res.setHeader('x-response-time', duration.toString());
      res.setHeader('x-response-size', responseSize.toString());
      
      // Log request completion
      (req as any).middleware.logRequestEnd(
        req,
        res,
        duration,
        responseSize,
        correlationId
      );
      
      return originalSend.call(this, body);
    };
    
    // Store middleware reference for response logging
    (req as any).middleware = this;
    
    next();
  }
  
  /**
   * Get existing correlation ID from headers or generate a new one
   */
  private getOrGenerateCorrelationId(req: Request): string {
    // Check multiple header variations
    const headerCorrelationId = 
      req.headers['x-correlation-id'] as string ||
      req.headers['x-request-id'] as string ||
      req.headers['x-trace-id'] as string ||
      req.headers['correlation-id'] as string;
    
    if (headerCorrelationId) {
      // Validate UUID format
      const uuidRegex = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;
      if (uuidRegex.test(headerCorrelationId)) {
        return headerCorrelationId;
      }
    }
    
    // Generate new correlation ID with DICE prefix
    return `dice_${uuidv4()}`;
  }
  
  /**
   * Extract session ID from various sources
   */
  private extractSessionId(req: Request): string | undefined {
    // Try session header first
    const sessionHeader = req.headers['x-session-id'] as string;
    if (sessionHeader) return sessionHeader;
    
    // Try session cookie
    const sessionCookie = req.headers.cookie?.match(/sessionId=([^;]+)/)?.[1];
    if (sessionCookie) return sessionCookie;
    
    // Try authorization header (JWT payload)
    const authHeader = req.headers.authorization;
    if (authHeader?.startsWith('Bearer ')) {
      try {
        const token = authHeader.substring(7);
        const payload = JSON.parse(Buffer.from(token.split('.')[1], 'base64').toString());
        return payload.sessionId;
      } catch (error) {
        // Ignore JWT parsing errors
      }
    }
    
    return undefined;
  }
  
  /**
   * Extract user ID from various sources
   */
  private extractUserId(req: Request): string | undefined {
    // Try user header first
    const userHeader = req.headers['x-user-id'] as string;
    if (userHeader) return userHeader;
    
    // Try authorization header (JWT payload)
    const authHeader = req.headers.authorization;
    if (authHeader?.startsWith('Bearer ')) {
      try {
        const token = authHeader.substring(7);
        const payload = JSON.parse(Buffer.from(token.split('.')[1], 'base64').toString());
        return payload.userId || payload.sub;
      } catch (error) {
        // Ignore JWT parsing errors
      }
    }
    
    // Try user cookie
    const userCookie = req.headers.cookie?.match(/userId=([^;]+)/)?.[1];
    if (userCookie) return userCookie;
    
    return undefined;
  }
  
  /**
   * Calculate request payload size
   */
  private calculateRequestSize(req: Request): number {
    try {
      const contentLength = req.headers['content-length'];
      if (contentLength) {
        return parseInt(contentLength, 10);
      }
      
      // Estimate size from body if available
      if (req.body) {
        return Buffer.byteLength(JSON.stringify(req.body), 'utf8');
      }
      
      return 0;
    } catch (error) {
      return 0;
    }
  }
  
  /**
   * Log request initiation with correlation context
   */
  private logRequestStart(
    req: Request,
    correlationId: string,
    sessionId?: string,
    userId?: string
  ): void {
    const sanitizedUrl = this.sanitizeUrl(req.url);
    const sanitizedIP = this.sanitizeIp(req.ip || req.connection.remoteAddress);
    const userAgent = req.headers['user-agent']?.substring(0, 200);
    
    this.logger.log('Request initiated', {
      correlationId,
      sessionId,
      userId,
      component: 'CorrelationMiddleware',
      action: 'request.start',
      metadata: {
        method: req.method,
        url: sanitizedUrl,
        ip: sanitizedIP,
        userAgent,
        requestSize: req.requestSize,
        headers: this.sanitizeHeaders(req.headers)
      },
      tags: ['request', 'correlation', 'middleware']
    });
  }
  
  /**
   * Log request completion with performance metrics
   */
  public logRequestEnd(
    req: Request,
    res: Response,
    duration: number,
    responseSize: number,
    correlationId: string
  ): void {
    const sanitizedUrl = this.sanitizeUrl(req.url);
    const sanitizedIP = this.sanitizeIp(req.ip || req.connection.remoteAddress);
    
    const logLevel = this.determineLogLevel(res.statusCode);
    const logMessage = `Request completed - ${req.method} ${sanitizedUrl}`;
    
    this.logger[logLevel](logMessage, {
      correlationId,
      sessionId: req.sessionId,
      userId: req.userId,
      component: 'CorrelationMiddleware',
      action: 'request.end',
      metadata: {
        method: req.method,
        url: sanitizedUrl,
        statusCode: res.statusCode,
        duration,
        requestSize: req.requestSize,
        responseSize,
        ip: sanitizedIP,
        userAgent: req.headers['user-agent']?.substring(0, 200)
      },
      tags: ['request', 'correlation', 'performance', 'middleware']
    });
    
    // Log slow requests as warnings
    if (duration > 5000) { // 5 seconds
      this.logger.warn('Slow request detected', {
        correlationId,
        sessionId: req.sessionId,
        userId: req.userId,
        component: 'CorrelationMiddleware',
        action: 'request.slow',
        metadata: {
          method: req.method,
          url: sanitizedUrl,
          statusCode: res.statusCode,
          duration,
          threshold: 5000
        },
        tags: ['performance', 'slow-request', 'monitoring']
      });
    }
  }
  
  /**
   * Determine appropriate log level based on status code
   */
  private determineLogLevel(statusCode: number): 'log' | 'warn' | 'error' {
    if (statusCode >= 500) return 'error';
    if (statusCode >= 400) return 'warn';
    return 'log';
  }
  
  /**
   * Sanitize URL to prevent log injection and remove sensitive data
   */
  private sanitizeUrl(url: string): string {
    // Remove query parameters that might contain sensitive data
    const [path, query] = url.split('?');
    
    if (!query) return path;
    
    const sanitizedQuery = query
      .split('&')
      .map(param => {
        const [key, value] = param.split('=');
        const sensitiveKeys = ['password', 'token', 'secret', 'key', 'auth'];
        
        if (sensitiveKeys.some(sensitive => key.toLowerCase().includes(sensitive))) {
          return `${key}=***`;
        }
        
        return param;
      })
      .join('&');
    
    return `${path}?${sanitizedQuery}`;
  }
  
  /**
   * Sanitize IP address for privacy compliance
   */
  private sanitizeIp(ip?: string): string | undefined {
    if (!ip) return undefined;
    
    // For IPv4, mask last octet
    if (ip.includes('.')) {
      const parts = ip.split('.');
      if (parts.length === 4) {
        return `${parts[0]}.${parts[1]}.${parts[2]}.xxx`;
      }
    }
    
    // For IPv6, mask last segment
    if (ip.includes(':')) {
      const parts = ip.split(':');
      if (parts.length > 1) {
        parts[parts.length - 1] = 'xxxx';
        return parts.join(':');
      }
    }
    
    return 'xxx.xxx.xxx.xxx';
  }
  
  /**
   * Sanitize request headers to remove sensitive information
   */
  private sanitizeHeaders(headers: any): any {
    const sanitized = { ...headers };
    const sensitiveHeaders = ['authorization', 'cookie', 'x-api-key', 'x-auth-token'];
    
    sensitiveHeaders.forEach(header => {
      if (sanitized[header]) {
        sanitized[header] = '***';
      }
    });
    
    return sanitized;
  }
} 