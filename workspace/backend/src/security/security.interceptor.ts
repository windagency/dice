import { Injectable, NestInterceptor, ExecutionContext, CallHandler, HttpException, HttpStatus, Logger } from '@nestjs/common';
import { Observable, throwError } from 'rxjs';
import { catchError, map } from 'rxjs/operators';

@Injectable()
export class SecurityInterceptor implements NestInterceptor {
  private readonly logger = new Logger(SecurityInterceptor.name);

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const request = context.switchToHttp().getRequest();
    const startTime = Date.now();

    return next.handle().pipe(
      map(data => {
        // Log successful requests (sanitized)
        this.logRequest(request, HttpStatus.OK, Date.now() - startTime);
        return data;
      }),
      catchError(error => {
        const duration = Date.now() - startTime;
        
        // Log security events
        this.logSecurityEvent(request, error, duration);
        
        // Sanitize error response to prevent information leakage
        const sanitizedError = this.sanitizeError(error);
        
        return throwError(() => sanitizedError);
      })
    );
  }

  private logRequest(request: any, statusCode: number, duration: number): void {
    const sanitizedLog = {
      method: request.method,
      url: this.sanitizeUrl(request.url),
      statusCode,
      duration,
      ip: this.sanitizeIp(request.ip),
      userAgent: request.headers['user-agent']?.substring(0, 100),
      timestamp: new Date().toISOString(),
    };

    this.logger.log(`Request processed: ${JSON.stringify(sanitizedLog)}`);
  }

  private logSecurityEvent(request: any, error: any, duration: number): void {
    const isSecurityRelevant = this.isSecurityRelevantError(error);
    
    if (isSecurityRelevant) {
      const securityLog = {
        event: 'SECURITY_ERROR',
        method: request.method,
        url: this.sanitizeUrl(request.url),
        statusCode: error.status || 500,
        errorType: error.constructor.name,
        duration,
        ip: this.sanitizeIp(request.ip),
        userAgent: request.headers['user-agent']?.substring(0, 100),
        timestamp: new Date().toISOString(),
        // Do NOT log error message or stack trace to prevent data leakage
      };

      this.logger.warn(`Security event: ${JSON.stringify(securityLog)}`);
    }
  }

  private sanitizeError(error: any): HttpException {
    // For known HTTP exceptions, return sanitized version
    if (error instanceof HttpException) {
      const status = error.getStatus();
      
      // Sanitize error messages based on status
      switch (status) {
        case HttpStatus.UNAUTHORIZED:
          return new HttpException('Authentication required', HttpStatus.UNAUTHORIZED);
        
        case HttpStatus.FORBIDDEN:
          return new HttpException('Access denied', HttpStatus.FORBIDDEN);
        
        case HttpStatus.NOT_FOUND:
          return new HttpException('Resource not found', HttpStatus.NOT_FOUND);
        
        case HttpStatus.CONFLICT:
          return new HttpException('Resource conflict', HttpStatus.CONFLICT);
        
        case HttpStatus.BAD_REQUEST:
          // For validation errors, return minimal information
          const response = error.getResponse();
          if (typeof response === 'object' && response['message']) {
            return new HttpException({
              error: 'Validation failed',
              statusCode: HttpStatus.BAD_REQUEST,
            }, HttpStatus.BAD_REQUEST);
          }
          return new HttpException('Invalid request', HttpStatus.BAD_REQUEST);
        
        case HttpStatus.TOO_MANY_REQUESTS:
          return error; // Rate limit errors are safe to return
        
        default:
          return new HttpException('Request failed', status);
      }
    }
    
    // For unknown errors, return generic 500
    return new HttpException('Internal server error', HttpStatus.INTERNAL_SERVER_ERROR);
  }

  private sanitizeUrl(url: string): string {
    // Remove query parameters that might contain sensitive data
    const urlObj = new URL(url, 'http://localhost');
    
    // Remove common sensitive query parameters
    const sensitiveParams = ['token', 'password', 'secret', 'key', 'auth'];
    sensitiveParams.forEach(param => {
      if (urlObj.searchParams.has(param)) {
        urlObj.searchParams.set(param, '[REDACTED]');
      }
    });
    
    return urlObj.pathname + urlObj.search;
  }

  private sanitizeIp(ip: string): string {
    // Hash IP for privacy while maintaining uniqueness for rate limiting
    if (!ip) return 'unknown';
    
    // For development, return partial IP
    if (process.env.NODE_ENV === 'development') {
      return ip.split('.').slice(0, 2).join('.') + '.xxx.xxx';
    }
    
    // For production, return hashed IP
    const crypto = require('crypto');
    return crypto.createHash('sha256').update(ip).digest('hex').substring(0, 8);
  }

  private isSecurityRelevantError(error: any): boolean {
    if (!error.status) return true; // Unknown errors are security relevant
    
    const securityRelevantStatuses = [
      HttpStatus.UNAUTHORIZED,
      HttpStatus.FORBIDDEN,
      HttpStatus.TOO_MANY_REQUESTS,
      HttpStatus.INTERNAL_SERVER_ERROR,
    ];
    
    return securityRelevantStatuses.includes(error.status);
  }
} 