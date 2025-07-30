import { Injectable, NestInterceptor, ExecutionContext, CallHandler, HttpException, HttpStatus } from '@nestjs/common';
import { Observable, throwError } from 'rxjs';
import { catchError, map } from 'rxjs/operators';
import { Request, Response } from 'express';
import { CorrelationAwareLogger } from '../infrastructure/logging/winston.config';

interface SecurityEvent {
  type: string;
  severity: 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL';
  source: string;
  action: string;
  outcome: 'blocked' | 'allowed' | 'flagged';
  riskScore: number;
  mitigationApplied: string[];
}

interface SecurityRequest {
  method: string;
  endpoint: string;
  ip: string;
  userAgent: string;
  sanitizedPayload?: any;
  headers?: Record<string, string>;
}

@Injectable()
export class EnhancedSecurityInterceptor implements NestInterceptor {
  private readonly logger = new CorrelationAwareLogger('EnhancedSecurityInterceptor');

  intercept(context: ExecutionContext, next: CallHandler): Observable<any> {
    const request = context.switchToHttp().getRequest<Request>();
    const response = context.switchToHttp().getResponse<Response>();
    const startTime = Date.now();

    // Log all requests for audit trail
    this.logRequest(request, response, startTime);

    return next.handle().pipe(
      map(data => {
        const duration = Date.now() - startTime;
        
        // Log successful requests
        this.logSuccessfulRequest(request, response, duration);
        
        return data;
      }),
      catchError(error => {
        const duration = Date.now() - startTime;
        
        // Enhanced security event logging
        this.logSecurityEvent(request, error, duration);
        
        // Sanitize error response to prevent information leakage
        const sanitizedError = this.sanitizeError(error);
        
        return throwError(() => sanitizedError);
      })
    );
  }

  private logRequest(request: Request, response: Response, startTime: number): void {
    const sanitizedLog = {
      method: request.method,
      url: this.sanitizeUrl(request.url),
      ip: this.sanitizeIp(request.ip),
      userAgent: request.headers['user-agent']?.substring(0, 100),
      contentType: request.headers['content-type'],
      contentLength: request.headers['content-length'],
      referer: request.headers['referer'],
      acceptLanguage: request.headers['accept-language'],
      timestamp: new Date().toISOString(),
      correlationId: request.correlationId,
      sessionId: request.sessionId,
      userId: request.userId
    };

    this.logger.info(
      `Security audit: ${request.method} request to ${this.sanitizeUrl(request.url)}`,
      'security.audit.request',
      sanitizedLog,
      request.correlationId,
      request.sessionId,
      request.userId
    );
  }

  private logSuccessfulRequest(request: Request, response: Response, duration: number): void {
    const logData = {
      method: request.method,
      url: this.sanitizeUrl(request.url),
      statusCode: response.statusCode,
      duration,
      ip: this.sanitizeIp(request.ip),
      userAgent: request.headers['user-agent']?.substring(0, 100),
      responseSize: response.get('content-length'),
      timestamp: new Date().toISOString()
    };

    this.logger.info(
      `Request processed successfully: ${request.method} ${this.sanitizeUrl(request.url)}`,
      'security.audit.success',
      logData,
      request.correlationId,
      request.sessionId,
      request.userId
    );
  }

  private logSecurityEvent(request: Request, error: any, duration: number): void {
    const isSecurityRelevant = this.isSecurityRelevantError(error);
    
    if (isSecurityRelevant) {
      const securityEvent = this.buildSecurityEvent(request, error);
      const securityRequest = this.buildSecurityRequest(request);
      const owaspCategory = this.mapToOwaspCategory(error);

      this.logger.security(
        `Security event detected: ${securityEvent.type}`,
        'security.event.detected',
        securityEvent,
        securityRequest,
        owaspCategory,
        request.correlationId
      );

      // Additional high-severity security logging
      if (securityEvent.severity === 'HIGH' || securityEvent.severity === 'CRITICAL') {
        this.logger.error(
          `Critical security event: ${securityEvent.type}`,
          'security.event.critical',
          error,
          {
            securityEvent,
            securityRequest,
            owaspCategory,
            duration,
            timestamp: new Date().toISOString()
          },
          request.correlationId,
          request.sessionId,
          request.userId
        );
      }
    }
  }

  private buildSecurityEvent(request: Request, error: any): SecurityEvent {
    const eventType = this.classifySecurityEvent(error);
    const severity = this.calculateSeverity(error);
    const riskScore = this.calculateRiskScore(request, error);
    const mitigations = this.getAppliedMitigations(request, error);

    return {
      type: eventType,
      severity,
      source: 'EnhancedSecurityInterceptor',
      action: `${request.method}:${request.route?.path || request.url}`,
      outcome: 'blocked',
      riskScore,
      mitigationApplied: mitigations
    };
  }

  private buildSecurityRequest(request: Request): SecurityRequest {
    return {
      method: request.method,
      endpoint: this.sanitizeUrl(request.url),
      ip: this.sanitizeIp(request.ip),
      userAgent: request.headers['user-agent']?.substring(0, 100) || 'unknown',
      sanitizedPayload: this.sanitizePayload(request.body),
      headers: this.sanitizeHeaders(request.headers)
    };
  }

  private isSecurityRelevantError(error: any): boolean {
    const securityStatusCodes = [400, 401, 403, 404, 422, 429, 500];
    const securityErrorTypes = [
      'UnauthorizedException',
      'ForbiddenException',
      'BadRequestException',
      'ValidationError',
      'ThrottlerException'
    ];

    return (
      securityStatusCodes.includes(error.status) ||
      securityErrorTypes.includes(error.constructor.name) ||
      this.containsSecurityKeywords(error.message)
    );
  }

  private containsSecurityKeywords(message: string): boolean {
    if (!message) return false;
    
    const securityKeywords = [
      'authentication', 'authorization', 'forbidden', 'unauthorized',
      'invalid token', 'expired token', 'malformed', 'injection',
      'xss', 'csrf', 'rate limit', 'too many requests'
    ];

    const lowerMessage = message.toLowerCase();
    return securityKeywords.some(keyword => lowerMessage.includes(keyword));
  }

  private classifySecurityEvent(error: any): string {
    const statusCode = error.status || 500;
    const errorType = error.constructor.name;

    switch (statusCode) {
      case 401:
        return 'AUTHENTICATION_FAILURE';
      case 403:
        return 'AUTHORIZATION_DENIED';
      case 429:
        return 'RATE_LIMIT_EXCEEDED';
      case 400:
        return 'MALFORMED_REQUEST';
      case 422:
        return 'VALIDATION_FAILURE';
      case 404:
        return 'RESOURCE_NOT_FOUND';
      default:
        if (errorType.includes('Validation')) return 'INPUT_VALIDATION_ERROR';
        if (errorType.includes('Throttler')) return 'RATE_LIMIT_VIOLATION';
        return 'SUSPICIOUS_ACTIVITY';
    }
  }

  private calculateSeverity(error: any): 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL' {
    const statusCode = error.status || 500;
    
    switch (statusCode) {
      case 401:
      case 403:
        return 'HIGH';
      case 429:
        return 'MEDIUM';
      case 500:
        return 'CRITICAL';
      case 400:
      case 422:
        return 'LOW';
      default:
        return 'MEDIUM';
    }
  }

  private calculateRiskScore(request: Request, error: any): number {
    let score = 0;
    
    // Base score based on error type
    const statusCode = error.status || 500;
    switch (statusCode) {
      case 401: score += 40; break;
      case 403: score += 50; break;
      case 429: score += 30; break;
      case 500: score += 70; break;
      default: score += 20; break;
    }
    
    // Increase score for repeated attempts (if tracked)
    // This would require session/IP tracking implementation
    
    // Increase score for sensitive endpoints
    if (this.isSensitiveEndpoint(request.url)) {
      score += 20;
    }
    
    // Increase score for suspicious user agents
    const userAgent = request.headers['user-agent'] || '';
    if (this.isSuspiciousUserAgent(userAgent)) {
      score += 15;
    }

    return Math.min(score, 100); // Cap at 100
  }

  private getAppliedMitigations(request: Request, error: any): string[] {
    const mitigations: string[] = [];
    
    if (error.status === 429) {
      mitigations.push('rate_limit');
    }
    
    if (error.status === 401 || error.status === 403) {
      mitigations.push('access_denied');
    }
    
    if (this.isSuspiciousRequest(request)) {
      mitigations.push('request_blocked');
    }
    
    return mitigations;
  }

  private mapToOwaspCategory(error: any): string {
    const statusCode = error.status || 500;
    
    switch (statusCode) {
      case 401:
      case 403:
        return 'A07:2021-Identification_and_Authentication_Failures';
      case 400:
      case 422:
        return 'A03:2021-Injection';
      case 429:
        return 'A06:2021-Vulnerable_and_Outdated_Components';
      case 500:
        return 'A09:2021-Security_Logging_and_Monitoring_Failures';
      case 404:
        return 'A05:2021-Security_Misconfiguration';
      default:
        return 'A10:2021-Server-Side_Request_Forgery';
    }
  }

  private sanitizeError(error: any): HttpException {
    if (error instanceof HttpException) {
      // For known HTTP exceptions, sanitize the response
      const status = error.getStatus();
      const sanitizedMessage = this.getSanitizedErrorMessage(status);
      
      return new HttpException(sanitizedMessage, status);
    }
    
    // For unknown errors, return generic server error
    return new HttpException('Internal server error', HttpStatus.INTERNAL_SERVER_ERROR);
  }

  private getSanitizedErrorMessage(status: number): string {
    switch (status) {
      case 400: return 'Bad request';
      case 401: return 'Authentication required';
      case 403: return 'Access forbidden';
      case 404: return 'Resource not found';
      case 422: return 'Validation failed';
      case 429: return 'Too many requests';
      case 500: return 'Internal server error';
      default: return 'Request failed';
    }
  }

  private sanitizeUrl(url: string): string {
    const sensitiveParams = ['password', 'token', 'secret', 'key', 'apikey', 'api_key'];
    let sanitizedUrl = url;

    sensitiveParams.forEach(param => {
      const regex = new RegExp(`([?&]${param}=)[^&]*`, 'gi');
      sanitizedUrl = sanitizedUrl.replace(regex, `$1***`);
    });

    return sanitizedUrl;
  }

  private sanitizeIp(ip: string): string {
    if (!ip) return 'unknown';
    
    const parts = ip.split('.');
    if (parts.length === 4) {
      return `${parts[0]}.${parts[1]}.${parts[2]}.xxx`;
    }
    
    const lastColon = ip.lastIndexOf(':');
    if (lastColon > 0) {
      return `${ip.substring(0, lastColon)}:xxxx`;
    }
    
    return 'xxx.xxx.xxx.xxx';
  }

  private sanitizePayload(payload: any): any {
    if (!payload) return null;
    
    const sensitiveFields = ['password', 'token', 'secret', 'key', 'apikey', 'api_key', 'creditCard', 'ssn'];
    const sanitized = { ...payload };
    
    sensitiveFields.forEach(field => {
      if (sanitized[field]) {
        sanitized[field] = '***';
      }
    });
    
    return sanitized;
  }

  private sanitizeHeaders(headers: any): Record<string, string> {
    const sanitized: Record<string, string> = {};
    const allowedHeaders = [
      'content-type', 'accept', 'user-agent', 'referer', 
      'accept-language', 'cache-control', 'x-forwarded-for'
    ];
    
    allowedHeaders.forEach(header => {
      if (headers[header]) {
        sanitized[header] = headers[header];
      }
    });
    
    return sanitized;
  }

  private isSensitiveEndpoint(url: string): boolean {
    const sensitivePatterns = [
      '/auth/', '/admin/', '/api/users/', '/api/settings/',
      '/payment/', '/billing/', '/profile/', '/password/'
    ];
    
    return sensitivePatterns.some(pattern => url.includes(pattern));
  }

  private isSuspiciousUserAgent(userAgent: string): boolean {
    const suspiciousPatterns = [
      'bot', 'crawler', 'spider', 'scraper', 'curl', 'wget',
      'python-requests', 'java/', 'go-http-client'
    ];
    
    const lowerAgent = userAgent.toLowerCase();
    return suspiciousPatterns.some(pattern => lowerAgent.includes(pattern));
  }

  private isSuspiciousRequest(request: Request): boolean {
    // Basic heuristics for suspicious requests
    const url = request.url.toLowerCase();
    const suspiciousPatterns = [
      'script', 'eval', 'exec', 'system', 'cmd',
      '../', '.env', 'passwd', 'shadow', 'config'
    ];
    
    return suspiciousPatterns.some(pattern => url.includes(pattern));
  }
} 