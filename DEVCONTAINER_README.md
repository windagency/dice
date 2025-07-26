# DICE DevContainer Setup Guide

## 🔒 Security-Compliant DevContainer Configuration

This guide explains the DICE project's DevContainer setup, which has been specifically configured to work with our enhanced security measures.

## 📁 Configuration Files

### Primary Files

| **File** | **Purpose** | **Security Notes** |
|----------|-------------|-------------------|
| `.devcontainer/devcontainer.json` | DevContainer configuration | ✅ Initializes environment files |
| `docker-compose.devcontainer.yml` | Simplified Docker Compose for DevContainer | ✅ Default values for required variables |
| `docker-compose.yml` | Production Docker Compose | ✅ Enforces required environment variables |
| `.env.development` | Development environment variables | ✅ Generated with secure secrets |

### Key Security Features

**🔐 Environment Variable Handling:**
- **DevContainer**: Uses safe defaults for development (e.g., `dice_dev_password_default`)
- **Production**: Enforces required environment variables with validation
- **Initialization**: Automatically creates `.env.development` from template

**🛡️ Container Security:**
- **Non-Root Users**: Backend and AWS CLI containers run as dedicated users
- **Volume Isolation**: Node modules isolated to prevent permission conflicts
- **Health Checks**: All services monitored for availability

## 🚀 Quick Start

### 1. Open in DevContainer

```bash
# VS Code with DevContainers extension
code .
# Then: Ctrl+Shift+P → "Reopen in Container"
```

### 2. DevContainer Process

1. **Initialize**: Creates `.env.development` from template
2. **Build**: Builds secure Docker images with non-root users
3. **Install**: Runs `pnpm install` for dependencies
4. **Setup**: Executes development environment setup script
5. **Ready**: All services available with health checks

### 3. Verify Setup

```bash
# Inside devcontainer
curl http://localhost:3001/health
curl http://localhost:3000
curl http://localhost:4566/_localstack/health
```

## 🔧 Configuration Details

### DevContainer-Specific Settings

```json
{
  "initializeCommand": "cp .env.sample .env.development 2>/dev/null || true",
  "dockerComposeFile": ["../docker-compose.devcontainer.yml"],
  "overrideCommand": false
}
```

### Safe Defaults for Development

```yaml
environment:
  POSTGRES_PASSWORD: ${POSTGRES_PASSWORD:-dice_dev_password_default}
  DATABASE_URL: ${DATABASE_URL:-postgresql://dice_user:dice_dev_password_default@postgres:5432/dice_db}
  JWT_SECRET: ${JWT_SECRET:-dice_jwt_secret_development_default}
```

## 🚨 Security Considerations

### Development vs Production

| **Environment** | **Approach** | **Security Level** |
|-----------------|--------------|-------------------|
| **DevContainer** | Safe defaults, automatic setup | 🟡 **DEVELOPMENT** |
| **Production** | Required variables, strict validation | 🔴 **PRODUCTION** |

### Best Practices

**✅ DO:**
- Use DevContainer for development and testing
- Generate secure secrets for production deployment
- Review `.env.development` contents before production use
- Test with production Docker Compose before deployment

**❌ DON'T:**
- Use DevContainer defaults in production
- Commit `.env.development` to version control
- Use weak or default passwords in production
- Skip environment variable validation

## 🛠️ Troubleshooting

### Common Issues

**🔧 "Required variable is missing" error:**
```bash
# Ensure .env.development exists
ls -la .env.development

# If missing, create from template
cp .env.sample .env.development
```

**🔧 Container permission issues:**
```bash
# Check container logs
docker compose -f docker-compose.devcontainer.yml logs backend
docker compose -f docker-compose.devcontainer.yml logs pwa
```

**🔧 Port conflicts:**
```bash
# Check for port usage
sudo lsof -i :3001 -i :3000 -i :5432 -i :6379 -i :4566
```

### Development Commands

```bash
# Start DevContainer services manually
docker compose -f docker-compose.devcontainer.yml up -d

# Check service health
docker compose -f docker-compose.devcontainer.yml ps

# View logs
docker compose -f docker-compose.devcontainer.yml logs -f

# Stop services
docker compose -f docker-compose.devcontainer.yml down
```

## 📚 Related Documentation

- [SECURITY.md](./SECURITY.md) - Comprehensive security guide
- [SERVICES_GUIDE.md](./SERVICES_GUIDE.md) - Service operations guide
- [TODO.md](./TODO.md) - Project roadmap and tasks

## 🎯 Migration Notes

If you were using the old DevContainer setup:

1. **Environment Variables**: Now automatically handled with safe defaults
2. **Security**: Enhanced with non-root users and proper permissions
3. **Profiles**: Simplified configuration without profile complications
4. **Health Checks**: All services now monitored for reliability

**The DevContainer now works seamlessly with our security improvements! 🔒✨** 