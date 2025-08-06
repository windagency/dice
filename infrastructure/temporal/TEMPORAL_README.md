# Temporal Workflow Development Guide

**Version**: 1.0 - Workflow Orchestration  
**Last Updated**: August 4, 2025  
**Status**: ✅ Production Ready

## 📋 **Overview**

Temporal.io provides workflow orchestration for complex business processes in the DICE D&D Character Management System. It enables reliable, scalable, and maintainable workflow execution with built-in fault tolerance and observability.

## 🏗️ **Architecture**

### **Temporal Components**

| Component           | Purpose              | Port | Description                          |
| ------------------- | -------------------- | ---- | ------------------------------------ |
| **Temporal Server** | Workflow engine      | 7233 | Core workflow execution engine       |
| **Temporal UI**     | Web dashboard        | 8088 | Workflow monitoring and management   |
| **PostgreSQL**      | Workflow persistence | 5432 | Workflow state and history storage   |
| **Redis**           | Workflow caching     | 6379 | Performance optimization and caching |

### **Configuration**

- **Temporal Server**: localhost:7233
- **Temporal UI**: localhost:8088
- **Database**: PostgreSQL integration
- **Namespace**: dice-character-management
- **Task Queue**: character-workflows

## 🚀 **Quick Start**

### **1. Start Temporal Services**

```bash
# Start Temporal with all dependencies
make dev-backend

# Or start individually
docker-compose -f workspace/backend/docker-compose.yml up temporal temporal-ui -d
```

### **2. Verify Temporal Health**

```bash
# Check Temporal server health
curl http://localhost:7233/health

# Check Temporal UI
curl http://localhost:8088/

# List workflows
tctl workflow list
```

### **3. Access Temporal UI**

Open your browser and navigate to:
- **Temporal UI**: http://localhost:8088
- **Workflow Dashboard**: http://localhost:8088/namespaces/dice-character-management

## 🔧 **Workflow Development**

### **Workflow Definition**

```typescript
// Example: Character Creation Workflow
import { proxyActivities, defineWorkflow } from '@temporalio/workflow';

const { validateCharacter, saveToDatabase, generateCharacterSheet } = proxyActivities({
  startToCloseTimeout: '1 minute',
});

export const createCharacterWorkflow = defineWorkflow('create-character', function* (characterData: CharacterData) {
  // Step 1: Validate character data
  const validationResult = yield validateCharacter(characterData);
  
  if (!validationResult.isValid) {
    throw new Error(`Character validation failed: ${validationResult.errors.join(', ')}`);
  }
  
  // Step 2: Save to database
  const savedCharacter = yield saveToDatabase(characterData);
  
  // Step 3: Generate character sheet
  const characterSheet = yield generateCharacterSheet(savedCharacter);
  
  return {
    characterId: savedCharacter.id,
    characterSheet: characterSheet,
    status: 'completed'
  };
});
```

### **Activity Implementation**

```typescript
// Example: Character Validation Activity
import { Activity } from '@temporalio/activity';

export async function validateCharacter(characterData: CharacterData): Promise<ValidationResult> {
  const errors: string[] = [];
  
  // Validate character name
  if (!characterData.name || characterData.name.length < 2) {
    errors.push('Character name must be at least 2 characters long');
  }
  
  // Validate character class
  const validClasses = ['Fighter', 'Wizard', 'Rogue', 'Cleric'];
  if (!validClasses.includes(characterData.class)) {
    errors.push(`Character class must be one of: ${validClasses.join(', ')}`);
  }
  
  // Validate character level
  if (characterData.level < 1 || characterData.level > 20) {
    errors.push('Character level must be between 1 and 20');
  }
  
  return {
    isValid: errors.length === 0,
    errors: errors
  };
}
```

### **Workflow Client**

```typescript
// Example: Starting a workflow
import { Client } from '@temporalio/client';

const client = new Client({
  namespace: 'dice-character-management',
});

export async function createCharacter(characterData: CharacterData) {
  const handle = await client.workflow.start('create-character', {
    taskQueue: 'character-workflows',
    workflowId: `create-character-${Date.now()}`,
    args: [characterData],
  });
  
  const result = await handle.result();
  return result;
}
```

## 📊 **Workflow Types**

### **Character Management Workflows**

#### **1. Character Creation Workflow**
- **Purpose**: Create new D&D characters
- **Activities**: Validation, database save, sheet generation
- **Duration**: 30 seconds to 2 minutes
- **Retry Policy**: 3 attempts with exponential backoff

#### **2. Character Update Workflow**
- **Purpose**: Update existing character data
- **Activities**: Validation, database update, sheet regeneration
- **Duration**: 15 seconds to 1 minute
- **Retry Policy**: 2 attempts with linear backoff

#### **3. Character Deletion Workflow**
- **Purpose**: Safely delete characters
- **Activities**: Backup creation, database deletion, cleanup
- **Duration**: 10 seconds to 30 seconds
- **Retry Policy**: 1 attempt (critical operation)

### **System Workflows**

#### **1. Data Migration Workflow**
- **Purpose**: Migrate character data between systems
- **Activities**: Data extraction, transformation, loading
- **Duration**: 5 minutes to 30 minutes
- **Retry Policy**: 5 attempts with exponential backoff

#### **2. Backup Workflow**
- **Purpose**: Create system backups
- **Activities**: Database backup, file compression, upload
- **Duration**: 2 minutes to 10 minutes
- **Retry Policy**: 3 attempts with linear backoff

## 🧪 **Testing Workflows**

### **Unit Testing**

```typescript
// Example: Workflow unit test
import { TestWorkflowEnvironment } from '@temporalio/testing';
import { createCharacterWorkflow } from '../workflows/character-workflows';

describe('Character Creation Workflow', () => {
  let testEnv: TestWorkflowEnvironment;
  
  beforeAll(async () => {
    testEnv = await TestWorkflowEnvironment.createLocal();
  });
  
  afterAll(async () => {
    await testEnv.teardown();
  });
  
  it('should create a valid character', async () => {
    const characterData = {
      name: 'Gandalf',
      class: 'Wizard',
      level: 10,
      race: 'Maia'
    };
    
    const result = await testEnv.client.workflow.execute(createCharacterWorkflow, {
      taskQueue: 'test-queue',
      workflowId: 'test-workflow',
      args: [characterData],
    });
    
    expect(result.characterId).toBeDefined();
    expect(result.status).toBe('completed');
  });
});
```

### **Integration Testing**

```typescript
// Example: Integration test with real database
describe('Character Workflow Integration', () => {
  it('should create character and save to database', async () => {
    const characterData = {
      name: 'Aragorn',
      class: 'Ranger',
      level: 8,
      race: 'Human'
    };
    
    const result = await createCharacter(characterData);
    
    // Verify database record
    const savedCharacter = await characterRepository.findById(result.characterId);
    expect(savedCharacter.name).toBe('Aragorn');
    expect(savedCharacter.class).toBe('Ranger');
  });
});
```

## 🔍 **Monitoring and Observability**

### **Temporal UI Dashboard**

Access the Temporal UI for workflow monitoring:

```bash
# Open Temporal UI
open http://localhost:8088
```

### **Workflow Metrics**

```typescript
// Example: Custom metrics
import { metrics } from '@temporalio/worker';

const characterCreationCounter = metrics.counter('character_creation_total', {
  description: 'Total number of character creation workflows',
});

const workflowDurationHistogram = metrics.histogram('workflow_duration_seconds', {
  description: 'Workflow execution duration',
  unit: 'seconds',
});
```

### **Logging**

```typescript
// Example: Structured logging
import { log } from '@temporalio/activity';

export async function validateCharacter(characterData: CharacterData) {
  log.info('Validating character', {
    characterName: characterData.name,
    characterClass: characterData.class,
    characterLevel: characterData.level,
  });
  
  // Validation logic...
  
  log.info('Character validation completed', {
    isValid: result.isValid,
    errorCount: result.errors.length,
  });
  
  return result;
}
```

## 🚨 **Troubleshooting**

### **Common Issues**

#### **1. Workflow Not Starting**

```bash
# Check Temporal server status
docker logs backend_temporal_dev

# Verify database connection
docker exec backend_postgres_dev pg_isready -U dice_user -d dice_db

# Check Temporal UI
curl http://localhost:8088/
```

#### **2. Activity Execution Failed**

```bash
# Check activity logs
docker logs backend_dev | grep -i "activity"

# Verify worker registration
docker logs backend_dev | grep -i "worker"
```

#### **3. Database Connection Issues**

```bash
# Check PostgreSQL status
docker exec backend_postgres_dev pg_isready -U dice_user -d dice_db

# Verify Temporal database tables
docker exec backend_postgres_dev psql -U dice_user -d dice_db -c "\dt"
```

### **Debug Commands**

```bash
# List all workflows
tctl workflow list

# Describe specific workflow
tctl workflow describe --workflow-id <workflow-id>

# Show workflow history
tctl workflow show --workflow-id <workflow-id>

# Terminate workflow
tctl workflow terminate --workflow-id <workflow-id>
```

## 📚 **Best Practices**

### **Workflow Design**

1. **Keep workflows deterministic** - No random operations
2. **Use activities for external calls** - Database, API, file operations
3. **Implement proper error handling** - Retry policies and fallbacks
4. **Design for idempotency** - Safe to retry operations
5. **Use appropriate timeouts** - Prevent hanging workflows

### **Activity Design**

1. **Keep activities focused** - Single responsibility
2. **Handle errors gracefully** - Proper error types and messages
3. **Use appropriate timeouts** - Prevent long-running activities
4. **Implement retry logic** - For transient failures
5. **Log important events** - For debugging and monitoring

### **Configuration Management**

```typescript
// Environment-based configuration
const temporalConfig = {
  namespace: process.env.TEMPORAL_NAMESPACE || 'dice-character-management',
  taskQueue: process.env.TEMPORAL_TASK_QUEUE || 'character-workflows',
  serverAddress: process.env.TEMPORAL_SERVER || 'localhost:7233',
};
```

## 🔐 **Security Considerations**

### **Workflow Security**

- **Namespace isolation** - Separate namespaces for different environments
- **Task queue security** - Proper task queue naming and access control
- **Workflow ID uniqueness** - Prevent workflow ID conflicts
- **Input validation** - Validate all workflow inputs
- **Output sanitization** - Sanitize workflow outputs

### **Data Security**

- **Encrypted connections** - Use TLS for Temporal server communication
- **Database security** - Secure PostgreSQL connections
- **Activity security** - Validate activity inputs and outputs
- **Logging security** - Avoid logging sensitive data

## 📞 **Support**

### **Documentation**

- [Temporal Documentation](https://docs.temporal.io/)
- [Temporal TypeScript SDK](https://docs.temporal.io/typescript)
- [DICE Development Guide](../SERVICES_GUIDE.md)

### **Community**

- [Temporal GitHub](https://github.com/temporalio/temporal)
- [Temporal Community](https://community.temporal.io/)

---

**🎯 RESULT**: Temporal provides **reliable workflow orchestration** for **complex business processes** with **built-in fault tolerance**!

---

**🛡️ Security-First • ⚡ Performance-Optimised • 🏗️ Enterprise-Ready** 