import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { Controller, Get, Post, Body, Param, Module } from '@nestjs/common';
import { TemporalService } from './temporal/temporal.service';
import { TemporalModule } from './temporal/temporal.module';
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
  async startExampleWorkflow(@Body() body: { userId: string; data?: any }) {
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
  async getWorkflowStatus(@Param('workflowId') workflowId: string) {
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
  async getWorkflowResult(@Param('workflowId') workflowId: string) {
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
  imports: [TemporalModule],
  controllers: [AppController],
})
class AppModule {}

async function bootstrap() {
  console.log('🎲 DICE Backend Service Starting...');
  
  try {
    const app = await NestFactory.create(AppModule);
    
    // Enable CORS for development
    app.enableCors();
    
    const port = process.env.PORT || 3001;
    await app.listen(port);
    
    console.log(`🚀 NestJS Server running on port ${port}`);
    console.log(`🏥 Health endpoint: http://localhost:${port}/health`);
    console.log(`🌀 Temporal endpoint: http://localhost:${port}/health/temporal`);
    console.log(`📡 API endpoint: http://localhost:${port}/`);
    
    // Start Temporal Worker in background
    console.log('🔄 Starting Temporal Worker...');
    startTemporalWorker().catch(error => {
      console.error('❌ Failed to start Temporal Worker:', error);
      // Don't exit the process if worker fails, but log the error
    });
    
  } catch (error) {
    console.error('❌ Failed to start server:', error);
    process.exit(1);
  }
}

bootstrap(); 