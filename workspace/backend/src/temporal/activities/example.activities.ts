/**
 * Example activities for Temporal workflows
 * Activities are functions that interact with external systems
 */

export async function greetUser(userId: string): Promise<string> {
  // Simulate some processing time
  await sleep(100);
  
  return `Hello, user ${userId}! Welcome to DICE.`;
}

export async function processData(data: any): Promise<any> {
  // Simulate data processing
  await sleep(200);
  
  return {
    originalData: data,
    processedAt: new Date().toISOString(),
    processed: true,
    summary: `Processed ${JSON.stringify(data).length} characters of data`,
  };
}

export async function sendNotification(userId: string, message: string): Promise<boolean> {
  // Simulate sending a notification
  await sleep(50);
  
  console.log(`📧 Sending notification to user ${userId}: ${message}`);
  return true;
}

function sleep(ms: number): Promise<void> {
  return new Promise(resolve => setTimeout(resolve, ms));
} 