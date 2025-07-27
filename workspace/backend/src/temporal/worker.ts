import { Connection, Worker } from '@temporalio/worker';
import * as activities from './activities/example.activities';

/**
 * Start a Temporal Worker
 * Workers poll task queues and execute workflows and activities
 */
export async function startTemporalWorker() {
  const temporalAddress = process.env.TEMPORAL_ADDRESS || 'localhost:7233';
  
  console.log(`🔄 Starting Temporal Worker connecting to ${temporalAddress}...`);
  
  try {
    // Create connection to Temporal server
    const connection = await Connection.connect({
      address: temporalAddress,
    });

    // Create and run worker
    const worker = await Worker.create({
      connection,
      namespace: 'default',
      taskQueue: 'dice-task-queue',
      workflowsPath: require.resolve('./workflows/example.workflow'),
      activities,
      maxConcurrentActivityTaskExecutions: 5,
      maxConcurrentWorkflowTaskExecutions: 5,
    });

    console.log('✅ Temporal Worker started successfully');
    console.log('📋 Task Queue: dice-task-queue');
    console.log('🔄 Worker polling for tasks...');

    // Start worker
    await worker.run();
  } catch (error) {
    console.error('❌ Failed to start Temporal Worker:', error);
    throw error;
  }
}

// Handle graceful shutdown
process.on('SIGINT', () => {
  console.log('🛑 Received SIGINT, shutting down Temporal Worker...');
  process.exit(0);
});

process.on('SIGTERM', () => {
  console.log('🛑 Received SIGTERM, shutting down Temporal Worker...');
  process.exit(0);
}); 