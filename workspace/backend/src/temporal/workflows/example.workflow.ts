import { proxyActivities } from '@temporalio/workflow';
import type * as activities from '../activities/example.activities';

// Configure activity timeouts and retry policies
const { greetUser, processData } = proxyActivities<typeof activities>({
  startToCloseTimeout: '1 minute',
  retry: {
    maximumAttempts: 3,
  },
});

export interface ExampleWorkflowInput {
  userId: string;
  data?: any;
}

export interface ExampleWorkflowResult {
  greeting: string;
  processedData?: any;
  completedAt: string;
}

/**
 * Example workflow demonstrating basic Temporal patterns
 * This workflow greets a user and optionally processes some data
 */
export async function exampleWorkflow(input: ExampleWorkflowInput): Promise<ExampleWorkflowResult> {
  // Step 1: Greet the user
  const greeting = await greetUser(input.userId);
  
  let processedData: any = null;
  
  // Step 2: If data is provided, process it
  if (input.data) {
    processedData = await processData(input.data);
  }
  
  return {
    greeting,
    processedData,
    completedAt: new Date().toISOString(),
  };
} 