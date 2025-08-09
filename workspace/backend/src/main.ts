import { Body, Controller, Get, MiddlewareConsumer, Module, Param, Post, Request, RequestMethod, UseGuards, ValidationPipe } from '@nestjs/common';
import { NestFactory } from '@nestjs/core';
import helmet from 'helmet';
import 'reflect-metadata';
import { AuthModule } from './auth/auth.module';
import { JwtAuthGuard } from './auth/guards/jwt-auth.guard';
import { logger, loggerConfig } from './logging/winston.config';
import { RateLimitMiddleware, authRateLimit, authSlowDown } from './security/rate-limit.middleware';
import { SecurityInterceptor } from './security/security.interceptor';
import { TemporalModule } from './temporal/temporal.module';
import { TemporalService } from './temporal/temporal.service';

@Controller()
class AppController {
  constructor(private readonly temporalService: TemporalService) { }

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
  const app = await NestFactory.create(AppModule, {
    logger: loggerConfig,
  });

  // Security middleware
  app.use(helmet());

  // Global interceptors
  app.useGlobalInterceptors(new SecurityInterceptor());

  // Global validation pipe
  app.useGlobalPipes(new ValidationPipe({
    transform: true,
    whitelist: true,
    forbidNonWhitelisted: true,
  }));

  // CORS configuration
  app.enableCors({
    origin: process.env.ALLOWED_ORIGINS?.split(',') || ['http://localhost:3000'],
    credentials: true,
  });

  const port = process.env.PORT || 3001;

  try {
    await app.listen(port);
    logger.info(`🎲 DICE Backend API started on port ${port}`);

    // Temporarily disable Temporal worker startup
    // await startTemporalWorker();
    logger.info('⏸️  Temporal worker startup disabled for debugging');

  } catch (error) {
    logger.error('❌ Failed to start server', error);
    process.exit(1);
  }
}

bootstrap(); 