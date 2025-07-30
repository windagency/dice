import { NativeConnection, Worker } from '@temporalio/worker';
import * as activities from './activities/example.activities';
import { logger, createLogContext } from '../logging/winston.config';

/**
 * Start a Temporal Worker
 * Workers poll task queues and execute workflows and activities
 */
export async function startTemporalWorker() {
  const workerContext = createLogContext('system', undefined, undefined, 'TemporalWorker');
  const temporalAddress = process.env.TEMPORAL_ADDRESS || 'localhost:7233';
  
  logger.info(`🔄 Starting Temporal Worker connecting to ${temporalAddress}...`, 'worker.starting', {
    temporalAddress,
    taskQueue: 'dice-task-queue'
  });
  
  try {
    // Create connection to Temporal server
    const connection = await NativeConnection.connect({
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

      logger.info('✅ Temporal Worker started successfully', 'worker.started', {
    taskQueue: 'dice-task-queue',
    temporalAddress,
    workflowsPath: require.resolve('./workflows'),
    status: 'polling'
  });

    // Start worker
    await worker.run();
  } catch (error) {
    logger.error('❌ Failed to start Temporal Worker', 'worker.startup_failed', error as Error, {
      temporalAddress,
      taskQueue: 'dice-task-queue'
    });
    throw error;
  }
}

// Handle graceful shutdown
// Note: These handlers are global and should ideally be managed by the main application
// For now, we'll keep them for completeness but in a production setup, 
// the main application should handle shutdown coordination 