# LocalStack Development Guide

**Version**: 1.0 - AWS Service Emulation  
**Last Updated**: August 4, 2025  
**Status**: ✅ Production Ready

## 📋 **Overview**

LocalStack provides AWS service emulation for local development, allowing you to test AWS integrations without connecting to the actual AWS cloud. This enables faster development cycles and cost-effective testing.

## 🏗️ **Architecture**

### **Services Available**

| Service      | Purpose                        | LocalStack Port | AWS Equivalent  |
| ------------ | ------------------------------ | --------------- | --------------- |
| **S3**       | Object storage emulation       | 4566            | Amazon S3       |
| **DynamoDB** | NoSQL database emulation       | 4566            | Amazon DynamoDB |
| **Kinesis**  | Stream processing emulation    | 4566            | Amazon Kinesis  |
| **SQS**      | Message queue emulation        | 4566            | Amazon SQS      |
| **SNS**      | Notification service emulation | 4566            | Amazon SNS      |

### **Configuration**

- **Port**: 4566 (unified endpoint for all services)
- **Region**: us-east-1 (default)
- **Access Key**: test
- **Secret Key**: test
- **Endpoint**: http://localhost:4566

## 🚀 **Quick Start**

### **1. Start LocalStack**

```bash
# Start LocalStack with all services
make start-aws

# Or start individually
docker-compose -f workspace/backend/docker-compose.yml up localstack -d
```

### **2. Verify Services**

```bash
# Check LocalStack health
curl http://localhost:4566/_localstack/health

# List available services
curl http://localhost:4566/_localstack/services
```

### **3. Test S3 Operations**

```bash
# Create a bucket
aws --endpoint-url=http://localhost:4566 s3 mb s3://dice-characters

# Upload a file
aws --endpoint-url=http://localhost:4566 s3 cp test.txt s3://dice-characters/

# List files
aws --endpoint-url=http://localhost:4566 s3 ls s3://dice-characters/
```

### **4. Test DynamoDB Operations**

```bash
# Create a table
aws --endpoint-url=http://localhost:4566 dynamodb create-table \
  --table-name dice-characters \
  --attribute-definitions AttributeName=id,AttributeType=S \
  --key-schema AttributeName=id,KeyType=HASH \
  --provisioned-throughput ReadCapacityUnits=5,WriteCapacityUnits=5

# Put an item
aws --endpoint-url=http://localhost:4566 dynamodb put-item \
  --table-name dice-characters \
  --item '{"id":{"S":"1"},"name":{"S":"Gandalf"},"class":{"S":"Wizard"}}'
```

## 🔧 **Integration with DICE**

### **Backend Integration**

The NestJS backend is configured to use LocalStack for AWS service emulation:

```typescript
// AWS SDK configuration for LocalStack
const awsConfig = {
  region: 'us-east-1',
  credentials: {
    accessKeyId: 'test',
    secretAccessKey: 'test'
  },
  endpoint: 'http://localhost:4566'
};
```

### **Frontend Integration**

The PWA frontend can interact with LocalStack services through the backend API:

```typescript
// Example: Upload character data to S3
const uploadCharacter = async (characterData: Character) => {
  const response = await fetch('/api/characters/upload', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(characterData)
  });
  return response.json();
};
```

## 📊 **Service-Specific Configuration**

### **S3 Configuration**

```yaml
# Docker Compose configuration
localstack:
  image: localstack/localstack:latest
  ports:
    - "4566:4566"
  environment:
    - SERVICES=s3,dynamodb,kinesis
    - DEFAULT_REGION=us-east-1
    - AWS_DEFAULT_REGION=us-east-1
    - DOCKER_HOST=unix:///var/run/docker.sock
  volumes:
    - "${LOCALSTACK_VOLUME_DIR:-./volume}:/var/lib/localstack"
    - "/var/run/docker.sock:/var/run/docker.sock"
```

### **DynamoDB Configuration**

```typescript
// Backend DynamoDB client configuration
import { DynamoDBClient } from '@aws-sdk/client-dynamodb';

const dynamoClient = new DynamoDBClient({
  region: 'us-east-1',
  endpoint: 'http://localhost:4566',
  credentials: {
    accessKeyId: 'test',
    secretAccessKey: 'test'
  }
});
```

### **Kinesis Configuration**

```typescript
// Backend Kinesis client configuration
import { KinesisClient } from '@aws-sdk/client-kinesis';

const kinesisClient = new KinesisClient({
  region: 'us-east-1',
  endpoint: 'http://localhost:4566',
  credentials: {
    accessKeyId: 'test',
    secretAccessKey: 'test'
  }
});
```

## 🧪 **Testing with LocalStack**

### **Unit Tests**

```typescript
// Example test for S3 operations
describe('S3 Service', () => {
  it('should upload character data to S3', async () => {
    const characterData = {
      id: '1',
      name: 'Gandalf',
      class: 'Wizard',
      level: 10
    };

    const result = await s3Service.uploadCharacter(characterData);
    expect(result.success).toBe(true);
  });
});
```

### **Integration Tests**

```typescript
// Example integration test
describe('Character Management', () => {
  it('should save character to DynamoDB and upload to S3', async () => {
    const character = await characterService.create({
      name: 'Aragorn',
      class: 'Ranger',
      level: 8
    });

    expect(character.id).toBeDefined();
    expect(character.s3Url).toBeDefined();
  });
});
```

## 🔍 **Monitoring and Debugging**

### **LocalStack Dashboard**

Access the LocalStack dashboard for service monitoring:

```bash
# Open LocalStack dashboard
open http://localhost:4566/_localstack/dashboard
```

### **Service Logs**

```bash
# View LocalStack logs
docker logs backend_localstack_dev

# Follow logs in real-time
docker logs -f backend_localstack_dev
```

### **Health Checks**

```bash
# Check LocalStack health
curl http://localhost:4566/_localstack/health

# Check specific service health
curl http://localhost:4566/_localstack/services/s3
```

## 🚨 **Troubleshooting**

### **Common Issues**

#### **1. Service Not Available**

```bash
# Check if LocalStack is running
docker ps | grep localstack

# Restart LocalStack
docker-compose restart localstack
```

#### **2. Connection Refused**

```bash
# Check port availability
lsof -i :4566

# Verify Docker container status
docker logs backend_localstack_dev
```

#### **3. AWS SDK Configuration**

Ensure your AWS SDK is configured for LocalStack:

```typescript
// Correct configuration
const awsConfig = {
  region: 'us-east-1',
  endpoint: 'http://localhost:4566',
  credentials: {
    accessKeyId: 'test',
    secretAccessKey: 'test'
  }
};
```

## 📚 **Best Practices**

### **Development Workflow**

1. **Start LocalStack** before running tests
2. **Use environment variables** for configuration
3. **Mock AWS services** in unit tests
4. **Use LocalStack** for integration tests
5. **Clean up resources** after testing

### **Configuration Management**

```typescript
// Environment-based configuration
const awsConfig = {
  region: process.env.AWS_REGION || 'us-east-1',
  endpoint: process.env.AWS_ENDPOINT || 'http://localhost:4566',
  credentials: {
    accessKeyId: process.env.AWS_ACCESS_KEY_ID || 'test',
    secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY || 'test'
  }
};
```

## 🔐 **Security Considerations**

### **Development Only**

- LocalStack is for development and testing only
- Never use LocalStack in production
- Use proper AWS credentials in production
- Implement proper IAM policies in production

### **Data Privacy**

- LocalStack data is stored locally
- No data is sent to AWS cloud
- Clear data regularly for testing
- Use test data only

## 📞 **Support**

### **Documentation**

- [LocalStack Documentation](https://docs.localstack.cloud/)
- [AWS SDK Documentation](https://docs.aws.amazon.com/sdk-for-javascript/)
- [DICE Development Guide](../SERVICES_GUIDE.md)

### **Community**

- [LocalStack GitHub](https://github.com/localstack/localstack)
- [AWS Developer Forums](https://forums.aws.amazon.com/)

---

**🎯 RESULT**: LocalStack provides **comprehensive AWS service emulation** for **cost-effective development** and **rapid testing**!

---

**🛡️ Security-First • ⚡ Performance-Optimised • 🏗️ Enterprise-Ready** 