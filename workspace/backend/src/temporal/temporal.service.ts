import { Injectable, OnModuleInit, OnModuleDestroy, Logger } from '@nestjs/common';
import { Connection, Client } from '@temporalio/client';

@Injectable()
export class TemporalService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(TemporalService.name);
  private connection: Connection;
  private client: Client;

  async onModuleInit() {
    const temporalAddress = process.env.TEMPORAL_ADDRESS || 'localhost:7233';
    
    try {
      this.logger.log(`🌀 Connecting to Temporal at ${temporalAddress}...`);
      
      this.connection = await Connection.connect({
        address: temporalAddress,
      });
      
      this.client = new Client({
        connection: this.connection,
        namespace: 'default',
      });
      
      this.logger.log('✅ Temporal client connected successfully');
    } catch (error) {
      this.logger.error('❌ Failed to connect to Temporal:', error);
      throw error;
    }
  }

  async onModuleDestroy() {
    if (this.connection) {
      await this.connection.close();
      this.logger.log('🔌 Temporal connection closed');
    }
  }

  getClient(): Client {
    if (!this.client) {
      throw new Error('Temporal client not initialised');
    }
    return this.client;
  }

  async getWorkflowHandle(workflowId: string) {
    return this.client.workflow.getHandle(workflowId);
  }

  async startWorkflow(workflowType: string, options: any) {
    return this.client.workflow.start(workflowType, options);
  }

  async describeWorkflow(workflowId: string) {
    const handle = await this.getWorkflowHandle(workflowId);
    return handle.describe();
  }

  async getWorkflowResult(workflowId: string) {
    const handle = await this.getWorkflowHandle(workflowId);
    return handle.result();
  }
} 