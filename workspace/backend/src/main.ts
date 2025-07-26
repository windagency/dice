import 'reflect-metadata';
import { NestFactory } from '@nestjs/core';
import { Controller, Get, Module } from '@nestjs/common';

@Controller()
class AppController {
  @Get()
  getRoot() {
    return { 
      message: '🎲 DICE Backend API', 
      version: '1.0.0', 
      status: 'running',
      timestamp: new Date().toISOString()
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
}

@Module({
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
    console.log(`📡 API endpoint: http://localhost:${port}/`);
  } catch (error) {
    console.error('❌ Failed to start server:', error);
    process.exit(1);
  }
}

bootstrap(); 