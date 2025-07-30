import { Injectable, NestInterceptor, ExecutionContext, CallHandler, HttpException, HttpStatus, Logger } from '@nestjs/common';
import { Observable, throwError } from 'rxjs';
import { catchError, map } from 'rxjs/operators';
import { createSecurityLogContext, createPerformanceLogContext } from '../logging/winston.config';

/**
 * Enhanced DICE Security Interceptor
 * Implements comprehensive security logging with correlation IDs
 * and OWASP Top 10 categorization as per DICE Unified Logging Plan
 */

@Injectable()
export class SecurityInterceptor implements NestInterceptor {
  private readonly logger = new Logger(SecurityInterceptor.name);

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const request = context.switchToHttp().getRequest();
    const response = context.switchToHttp().getResponse();
    const startTime = Date.now();
    
    // Extract correlation context
    const correlationId = request.correlationId || 'unknown';
    const sessionId = request.sessionId;
    const userId = request.userId;

    return next.handle().pipe(
      map(data => {
        const duration = Date.now() - startTime;
        
        // Log successful requests with performance metrics
        this.logSuccessfulRequest(request, response, duration, correlationId, sessionId, userId);
        
        return data;
      }),
      catchError(error => {
        const duration = Date.now() - startTime;
        
        // Enhanced security event logging
        this.logSecurityEvent(request, error, duration, correlationId, sessionId, userId);
        
        // Sanitize error response to prevent information leakage
        const sanitizedError = this.sanitizeError(error);
        
        return throwError(() => sanitizedError);
      })
    );
  }

  /**
   * Log successful requests with performance metrics
   */
  private logSuccessfulRequest(
    request: any, 
    response: any, 
    duration: number, 
    correlationId: string, 
    sessionId?: string, 
    userId?: string
  ): void {
    const performanceContext = createPerformanceLogContext(
      correlationId,
      duration,
      response.statusCode || HttpStatus.OK,
      'SecurityInterceptor',
      'request.success'
    );

    this.logger.log('Request processed successfully', {
      ...performanceContext,
      sessionId,
      userId,
      metadata: {
        ...performanceContext.metadata,
        method: request.method,
        url: this.sanitizeUrl(request.url),
        ip: this.sanitizeIp(request.ip),
        userAgent: request.headers['user-agent']?.substring(0, 200),
        requestSize: request.requestSize,
        responseSize: response.get('content-length')
      },
      tags: [...performanceContext.tags, 'success', 'audit']
    });

    // Log performance warning for slow requests
    if (duration > 1000) {
      this.logger.warn('Slow request detected by SecurityInterceptor', {
        correlationId,
        sessionId,
        userId,
        component: 'SecurityInterceptor',
        action: 'request.slow',
        metadata: {
          method: request.method,
          url: this.sanitizeUrl(request.url),
          duration,
          threshold: 1000,
          statusCode: response.statusCode
        },
        tags: ['performance', 'slow-request', 'monitoring']
      });
    }
  }

  /**
   * Enhanced security event logging with OWASP categorization
   */
  private logSecurityEvent(
    request: any, 
    error: any, 
    duration: number, 
    correlationId: string, 
    sessionId?: string, 
    userId?: string
  ): void {
    const isSecurityRelevant = this.isSecurityRelevantError(error);
    
    if (isSecurityRelevant) {
      const securityEvent = {
        type: this.classifySecurityEventType(error),
        severity: this.calculateSecuritySeverity(error),
        source: 'SecurityInterceptor',
        action: `${request.method}:${this.extractEndpoint(request)}`,
        outcome: 'blocked',
        riskScore: this.calculateRiskScore(request, error),
        mitigationApplied: this.getAppliedMitigations(error),
        errorType: error.constructor.name,
        statusCode: error.status || 500
      };

      const owaspCategory = this.mapToOwaspCategory(error);
      
      const securityContext = createSecurityLogContext(
        correlationId,
        securityEvent,
        owaspCategory,
        sessionId,
        userId
      );

      this.logger.warn('Security event detected', {
        ...securityContext,
        message: `Security violation: ${securityEvent.type}`,
        metadata: {
          method: request.method,
          url: this.sanitizeUrl(request.url),
          ip: this.sanitizeIp(request.ip),
          userAgent: request.headers['user-agent']?.substring(0, 200),
          duration,
          requestSize: request.requestSize,
          sanitizedPayload: this.sanitizePayload(request.body)
        },
        tags: [...securityContext.tags, 'security-event', 'threat-detection']
      });

      // Log critical security events with higher severity
      if (securityEvent.severity === 'CRITICAL' || securityEvent.riskScore > 80) {
        this.logger.error('Critical security event', {
          ...securityContext,
          message: `CRITICAL: ${securityEvent.type} - Risk Score: ${securityEvent.riskScore}`,
          metadata: {
            method: request.method,
            url: this.sanitizeUrl(request.url),
            ip: this.sanitizeIp(request.ip),
            criticalIndicators: this.getCriticalIndicators(request, error)
          },
          tags: [...securityContext.tags, 'critical-security', 'alert']
        });
      }
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
      HttpStatus.BAD_REQUEST,
      HttpStatus.NOT_FOUND,
      HttpStatus.UNPROCESSABLE_ENTITY
    ];
    
    return securityRelevantStatuses.includes(error.status);
  }

  /**
   * Classify security event type based on error characteristics
   */
  private classifySecurityEventType(error: any): string {
    if (error instanceof HttpException) {
      const status = error.getStatus();
      switch (status) {
        case 401: return 'AUTHENTICATION_FAILURE';
        case 403: return 'AUTHORIZATION_DENIED';
        case 404: return 'RESOURCE_NOT_FOUND';
        case 422: return 'INPUT_VALIDATION_FAILURE';
        case 429: return 'RATE_LIMIT_EXCEEDED';
        case 400: return 'BAD_REQUEST';
        case 500: return 'SERVER_ERROR';
        default: return 'GENERIC_SECURITY_EVENT';
      }
    }
    
    const errorName = error.constructor.name;
    if (errorName.includes('Validation')) return 'INPUT_VALIDATION_FAILURE';
    if (errorName.includes('Unauthorized')) return 'AUTHENTICATION_FAILURE';
    if (errorName.includes('Forbidden')) return 'AUTHORIZATION_DENIED';
    if (errorName.includes('TooManyRequests')) return 'RATE_LIMIT_EXCEEDED';
    
    return 'UNKNOWN_SECURITY_EVENT';
  }

  /**
   * Calculate security event severity
   */
  private calculateSecuritySeverity(error: any): string {
    if (error instanceof HttpException) {
      const status = error.getStatus();
      if (status === 401 || status === 403) return 'HIGH';
      if (status === 429) return 'MEDIUM';
      if (status === 500) return 'CRITICAL';
      if (status >= 400 && status < 500) return 'MEDIUM';
    }
    
    return 'LOW';
  }

  /**
   * Calculate risk score based on request characteristics and error type
   */
  private calculateRiskScore(request: any, error: any): number {
    let score = 0;
    
    // Base score from error type
    if (error instanceof HttpException) {
      const status = error.getStatus();
      if (status === 401) score += 40;
      else if (status === 403) score += 50;
      else if (status === 429) score += 30;
      else if (status === 500) score += 60;
      else score += 20;
    }
    
    // Additional risk factors
    const ip = request.ip || '';
    const userAgent = request.headers['user-agent'] || '';
    const url = request.url || '';
    
    // Suspicious patterns in URL
    if (url.includes('admin') || url.includes('api/v') || url.includes('auth')) score += 10;
    if (url.includes('..') || url.includes('<script') || url.includes('union')) score += 30;
    
    // Suspicious user agents
    if (userAgent.includes('bot') || userAgent.includes('scanner') || userAgent.length < 10) score += 15;
    
    return Math.min(score, 100); // Cap at 100
  }

  /**
   * Get applied mitigation measures
   */
  private getAppliedMitigations(error: any): string[] {
    const mitigations: string[] = [];
    
    if (error instanceof HttpException) {
      const status = error.getStatus();
      
      switch (status) {
        case 401:
          mitigations.push('authentication_required');
          break;
        case 403:
          mitigations.push('access_denied');
          break;
        case 429:
          mitigations.push('rate_limit_applied');
          break;
        case 422:
          mitigations.push('input_validation');
          break;
        default:
          mitigations.push('error_response');
      }
    }
    
    mitigations.push('request_sanitization');
    mitigations.push('response_sanitization');
    
    return mitigations;
  }

  /**
   * Map error to OWASP Top 10 category
   */
  private mapToOwaspCategory(error: any): string {
    if (error instanceof HttpException) {
      const status = error.getStatus();
      
      switch (status) {
        case 401:
          return 'A07:2021-Identification_and_Authentication_Failures';
        case 403:
          return 'A01:2021-Broken_Access_Control';
        case 422:
        case 400:
          return 'A03:2021-Injection';
        case 429:
          return 'A04:2021-Insecure_Design';
        case 500:
          return 'A09:2021-Security_Logging_and_Monitoring_Failures';
        case 404:
          return 'A01:2021-Broken_Access_Control';
        default:
          return 'A10:2021-Server-Side_Request_Forgery';
      }
    }
    
    return 'A00:2021-Unknown_Security_Risk';
  }

  /**
   * Extract endpoint pattern from request
   */
  private extractEndpoint(request: any): string {
    const url = request.url || '';
    // Remove query parameters and extract route pattern
    const path = url.split('?')[0];
    
    // Replace IDs with placeholders for better grouping
    return path.replace(/\/\d+/g, '/:id')
               .replace(/\/[a-f0-9-]{36}/g, '/:uuid')
               .replace(/\/[a-f0-9]{24}/g, '/:objectId');
  }

  /**
   * Get critical security indicators
   */
  private getCriticalIndicators(request: any, error: any): string[] {
    const indicators: string[] = [];
    
    const url = request.url || '';
    const userAgent = request.headers['user-agent'] || '';
    
    // SQL injection patterns
    if (url.match(/(union|select|insert|update|delete|drop|create|alter)/i)) {
      indicators.push('sql_injection_attempt');
    }
    
    // XSS patterns
    if (url.match(/(<script|javascript:|onload=|onerror=)/i)) {
      indicators.push('xss_attempt');
    }
    
    // Path traversal
    if (url.includes('..') || url.includes('%2e%2e')) {
      indicators.push('path_traversal_attempt');
    }
    
    // Suspicious user agents
    if (userAgent.match(/(sqlmap|nmap|nikto|burp|owasp)/i)) {
      indicators.push('security_tool_detected');
    }
    
    // Admin panel access attempts
    if (url.match(/(admin|administrator|wp-admin|phpmyadmin)/i)) {
      indicators.push('admin_access_attempt');
    }
    
    return indicators;
  }

  /**
   * Sanitize request payload for logging
   */
  private sanitizePayload(payload: any): any {
    if (!payload || typeof payload !== 'object') {
      return payload;
    }

    const sanitized = { ...payload };
    const sensitiveFields = ['password', 'token', 'secret', 'key', 'auth', 'credential'];
    
    const sanitizeObject = (obj: any): any => {
      if (Array.isArray(obj)) {
        return obj.map(item => sanitizeObject(item));
      }
      
      if (obj && typeof obj === 'object') {
        const result = {};
        for (const [key, value] of Object.entries(obj)) {
          if (sensitiveFields.some(field => key.toLowerCase().includes(field))) {
            result[key] = '***';
          } else {
            result[key] = sanitizeObject(value);
          }
        }
        return result;
      }
      
      return obj;
    };

    return sanitizeObject(sanitized);
  }
} 