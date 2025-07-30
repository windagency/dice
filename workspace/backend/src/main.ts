import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import helmet from 'helmet';
import { Controller, Get, Post, Body, Param, Module, UseGuards, Request, ValidationPipe, MiddlewareConsumer, RequestMethod } from '@nestjs/common';
import { TemporalService } from './temporal/temporal.service';
import { TemporalModule } from './temporal/temporal.module';
import { AuthModule } from './auth/auth.module';
import { JwtAuthGuard } from './auth/guards/jwt-auth.guard';
import { SecurityInterceptor } from './security/security.interceptor';
import { CorrelationMiddleware } from './middleware/correlation.middleware';
import { RateLimitMiddleware, authRateLimit, authSlowDown } from './security/rate-limit.middleware';
import { loggerConfig, createLogContext, logger } from './logging/winston.config';
import { startTemporalWorker } from './temporal/worker';

@Controller()
class AppController {
  constructor(private readonly temporalService: TemporalService) {}

  @Get()
  getRoot() {
    return { 
      message: '🎲 DICE Backend API', 
      version: '1.0.0', 
      status: 'running',
      timestamp: new Date().toISOString(),
      features: ['workflows', 'temporal']
    };
  }

  @Get('health')
  getHealth() {
    return { 
      status: 'ok', 
      service: 'dice-backend', 
      timestamp: new Date().toISOString(),
      uptime: process.uptime()
    };
  }

  @Get('health/temporal')
  async getTemporalHealth() {
    try {
      const client = this.temporalService.getClient();
      // Simple connectivity check
      await client.connection.workflowService.getSystemInfo({});
      
      return {
        status: 'ok',
        service: 'temporal',
        timestamp: new Date().toISOString(),
        connection: 'connected'
      };
    } catch (error) {
      return {
        status: 'error',
        service: 'temporal',
        timestamp: new Date().toISOString(),
        connection: 'disconnected',
        error: error.message
      };
    }
  }

  @Post('workflows/example')
  @UseGuards(JwtAuthGuard)
  async startExampleWorkflow(@Body() body: { userId: string; data?: any }, @Request() req: any) {
    try {
      const workflowId = `example-workflow-${Date.now()}`;
      
      const handle = await this.temporalService.getClient().workflow.start('exampleWorkflow', {
        taskQueue: 'dice-task-queue',
        workflowId,
        args: [{ userId: body.userId, data: body.data }],
      });

      return {
        workflowId,
        runId: handle.firstExecutionRunId,
        status: 'started',
        timestamp: new Date().toISOString()
      };
    } catch (error) {
      return {
        status: 'error',
        error: error.message,
        timestamp: new Date().toISOString()
      };
    }
  }

  @Get('workflows/:workflowId')
  @UseGuards(JwtAuthGuard)
  async getWorkflowStatus(@Param('workflowId') workflowId: string, @Request() req: any) {
    try {
      const description = await this.temporalService.describeWorkflow(workflowId);
      
      return {
        workflowId,
        status: description.status.name,
        startTime: description.startTime,
        executionTime: description.executionTime,
        timestamp: new Date().toISOString()
      };
    } catch (error) {
      return {
        status: 'error',
        error: error.message,
        timestamp: new Date().toISOString()
      };
    }
  }

  @Get('workflows/:workflowId/result')
  @UseGuards(JwtAuthGuard)
  async getWorkflowResult(@Param('workflowId') workflowId: string, @Request() req: any) {
    try {
      const result = await this.temporalService.getWorkflowResult(workflowId);
      
      return {
        workflowId,
        result,
        timestamp: new Date().toISOString()
      };
    } catch (error) {
      return {
        status: 'error',
        error: error.message,
        timestamp: new Date().toISOString()
      };
    }
  }
}

@Module({
  imports: [TemporalModule, AuthModule],
  controllers: [AppController],
  providers: [SecurityInterceptor, RateLimitMiddleware],
})
class AppModule {
  configure(consumer: MiddlewareConsumer) {
    // Apply auth rate limiting and slowdown to authentication endpoints
    consumer
      .apply(authRateLimit, authSlowDown)
      .forRoutes(
        { path: 'auth/register', method: RequestMethod.POST },
        { path: 'auth/login', method: RequestMethod.POST }
      );

    // Apply general rate limiting to all routes
    consumer
      .apply(RateLimitMiddleware)
      .forRoutes('*');
  }
}

async function bootstrap() {
  const bootstrapContext = createLogContext('system', undefined, undefined, 'Bootstrap');
  logger.info('🎲 DICE Backend Service Starting...', {
    ...bootstrapContext,
    action: 'service.startup',
    metadata: {
      nodeVersion: process.version,
      environment: process.env.NODE_ENV || 'development',
      port: process.env.PORT || 3001
    },
    tags: ['startup', 'bootstrap']
  });
  
  try {
    const app = await NestFactory.create(AppModule, {
      logger: loggerConfig
    });
    
    // Security headers
    app.use(helmet({
      contentSecurityPolicy: {
        directives: {
          defaultSrc: ["'self'"],
          styleSrc: ["'self'", "'unsafe-inline'"], // Allow inline styles for development
          scriptSrc: ["'self'"],
          imgSrc: ["'self'", "data:", "https:"],
          connectSrc: ["'self'"],
          fontSrc: ["'self'"],
          objectSrc: ["'none'"],
          mediaSrc: ["'self'"],
          frameSrc: ["'none'"],
        },
      },
      crossOriginEmbedderPolicy: false, // Disable for development
      // forceHTTPSRedirect: process.env.NODE_ENV === 'production', // Force HTTPS in production (not available in this helmet version)
      hsts: process.env.NODE_ENV === 'production' ? {
        maxAge: 31536000, // 1 year
        includeSubDomains: true,
        preload: true
      } : false,
    }));

    // Global validation pipe
    app.useGlobalPipes(new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
      disableErrorMessages: process.env.NODE_ENV === 'production', // Hide validation details in production
    }));

    // Global correlation middleware (must be first)
    app.use(new CorrelationMiddleware().use.bind(new CorrelationMiddleware()));
    
    // Global security interceptor
    app.useGlobalInterceptors(new SecurityInterceptor());
    
    // Configure CORS properly
    const corsOptions = {
      origin: process.env.NODE_ENV === 'production' 
        ? ['https://yourdomain.com'] // Replace with actual production domains
        : ['http://localhost:3000', 'http://localhost:6006'], // Allow PWA and Storybook in development
      methods: ['GET', 'POST', 'PUT', 'DELETE', 'PATCH', 'OPTIONS'],
      allowedHeaders: ['Content-Type', 'Authorization'],
      credentials: true,
    };
    
    app.enableCors(corsOptions);
    
    const port = process.env.PORT || 3001;
    await app.listen(port);
    
    const serverContext = createLogContext('system', undefined, undefined, 'Bootstrap');
    logger.info('🚀 NestJS Server running successfully', {
      ...serverContext,
      action: 'service.started',
      metadata: {
        port,
        environment: process.env.NODE_ENV || 'development',
        endpoints: {
          health: `http://localhost:${port}/health`,
          temporal: `http://localhost:${port}/health/temporal`,
          auth: `http://localhost:${port}/auth/`,
          api: `http://localhost:${port}/`
        }
      },
      tags: ['startup', 'server', 'ready']
    });
    
    if (process.env.NODE_ENV !== 'production') {
      logger.warn('⚠️ Running in development mode with relaxed security', {
        ...serverContext,
        action: 'service.development_mode',
        metadata: {
          environment: process.env.NODE_ENV || 'development',
          securityLevel: 'relaxed'
        },
        tags: ['security', 'development', 'warning']
      });
    }
    
    // Start Temporal Worker in background
    logger.info('🔄 Starting Temporal Worker...', {
      ...serverContext,
      action: 'temporal.worker.starting',
      tags: ['temporal', 'worker', 'startup']
    });
    
    startTemporalWorker().catch(error => {
      logger.error('❌ Failed to start Temporal Worker', {
        ...serverContext,
        action: 'temporal.worker.startup_failed',
        metadata: {
          temporalAddress: process.env.TEMPORAL_ADDRESS || 'localhost:7233',
          error: {
            name: error.name,
            message: error.message,
            stack: error.stack
          }
        },
        tags: ['temporal', 'worker', 'error']
      });
      // Don't exit the process if worker fails, but log the error
    });
    
  } catch (error) {
    logger.error('❌ Failed to start server', {
      ...bootstrapContext,
      action: 'service.startup_failed',
      metadata: {
        error: {
          name: error.name,
          message: error.message,
          stack: error.stack
        },
        nodeVersion: process.version,
        environment: process.env.NODE_ENV || 'development'
      },
      tags: ['startup', 'error', 'critical']
    });
    process.exit(1);
  }
}

bootstrap(); 