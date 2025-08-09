import { Injectable, Logger, OnModuleDestroy, OnModuleInit } from '@nestjs/common';
import { Client, Connection } from '@temporalio/client';

@Injectable()
export class TemporalService implements OnModuleInit, OnModuleDestroy {
  private readonly logger = new Logger(TemporalService.name);
  private connection: Connection;
  private client: Client;

  async onModuleInit() {
    // Temporarily disable Temporal connection for debugging
    this.logger.log('⏸️  Temporal service initialization disabled for debugging');
    return;

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