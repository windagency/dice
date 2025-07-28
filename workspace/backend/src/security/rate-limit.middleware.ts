import { Injectable, NestMiddleware } from '@nestjs/common';
import { Request, Response, NextFunction } from 'express';
import rateLimit from 'express-rate-limit';
import slowDown from 'express-slow-down';

// Strict rate limiting for authentication endpoints
export const authRateLimit = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 5, // 5 attempts per window
  message: {
    error: 'Too many authentication attempts',
    message: 'Please try again in 15 minutes',
    statusCode: 429,
  },
  standardHeaders: true,
  legacyHeaders: false,
  skip: (req) => {
    // Skip rate limiting in development for testing
    return process.env.NODE_ENV === 'development' && req.headers['x-test-mode'] === 'true';
  },
});

// Progressive slowdown for repeated attempts
export const authSlowDown: any = slowDown({
  windowMs: 15 * 60 * 1000, // 15 minutes
  delayAfter: 2, // Allow 2 requests per window at full speed
  delayMs: (hits) => hits * 1000, // Add 1 second delay per hit after delayAfter
  maxDelayMs: 10000, // Maximum 10 second delay
});

// General API rate limiting
export const generalRateLimit = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 100, // 100 requests per window
  message: {
    error: 'Too many requests',
    message: 'Please try again later',
    statusCode: 429,
  },
  standardHeaders: true,
  legacyHeaders: false,
});

@Injectable()
export class RateLimitMiddleware implements NestMiddleware {
  use(req: Request, res: Response, next: NextFunction) {
    // Apply general rate limiting to all endpoints
    generalRateLimit(req, res, next);
  }
} 