# DICE DevContainer Development Environment

This directory contains the DevContainer configuration for the **DICE D&D Character Management System**. The DevContainer provides a complete, isolated development environment with all necessary services and tools pre-configured.

## 🏗️ Architecture Overview

The DevContainer environment includes:

- **Backend API** (NestJS + TypeScript)
- **PWA Frontend** (Astro.js + React + Tailwind CSS)
- **Component Library** (Storybook)
- **Workflow Engine** (Temporal.io)
- **Database** (PostgreSQL)
- **Cache** (Redis)
- **AWS Services** (LocalStack)
- **Reverse Proxy** (Traefik)

## 📋 Requirements

- [Docker](https://www.docker.com/get-started)
- [Visual Studio Code](https://code.visualstudio.com/)
- [Dev Containers Extension](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers)

## 🚀 Quick Start

### 1. Prepare the Environment

Run the setup script to configure the DevContainer for your system:

  ```bash
  # From the project root
  infrastructure/scripts/setup-devcontainer.sh
  ```

This script will:
- Configure user permissions dynamically
- Create necessary environment files
- Set up directory structure
- Validate Docker Compose configuration

### 2. Open in DevContainer

1. Open the project in VS Code
2. Install the **Dev Containers** extension if not already installed
3. Use the command palette (`Cmd/Ctrl + Shift + P`)
4. Run: **Dev Containers: Reopen in Container**
5. Wait for the environment to build and start (first time may take 5-10 minutes)

### 3. Verify Services

Once the container is running, all services should be available:

| Service               | URL                                            | Purpose                               |
| --------------------- | ---------------------------------------------- | ------------------------------------- |
| **Backend API**       | [http://localhost:3001](http://localhost:3001) | NestJS REST API with health endpoints |
| **PWA Frontend**      | [http://localhost:3000](http://localhost:3000) | Character management interface        |
| **Storybook**         | [http://localhost:6006](http://localhost:6006) | Component library playground          |
| **Temporal UI**       | [http://localhost:8088](http://localhost:8088) | Workflow monitoring dashboard         |
| **Traefik Dashboard** | [http://localhost:8080](http://localhost:8080) | Reverse proxy management              |

## 🔧 Configuration Files

### Core Configuration

- **`devcontainer.json`** - Main DevContainer configuration
- **`docker-compose.yml`** - Service orchestration for development
- **`.env`** - Environment variables for DevContainer
- **`infrastructure/scripts/setup-devcontainer.sh`** - Environment preparation script

### Key Features

#### Dynamic User Configuration
The setup automatically detects your host user ID and group ID to prevent permission issues:

```bash
# Automatically set in .env
DOCKER_USER=502    # Your host UID
DOCKER_GROUP=20    # Your host GID
```

#### Port Forwarding
All development ports are automatically forwarded:

```json
"forwardPorts": [
  3001,  // Backend API
  3000,  // PWA Frontend  
  6006,  // Storybook Component Library
  5432,  // PostgreSQL
  6379,  // Redis
  7233,  // Temporal gRPC
  8080,  // Traefik Dashboard
  8088,  // Temporal Web UI
  4566   // LocalStack AWS Services
]
```

#### VS Code Extensions
Pre-configured development tools:

- **Language Support**: TypeScript, ESLint, Prettier
- **Framework Support**: Astro, Tailwind CSS
- **DevOps Tools**: Docker, YAML support
- **Development Tools**: Thunder Client, Spell Checker
- **Temporal**: Official Temporal extension

## 🛠️ Development Workflow

### Starting Development

Once inside the DevContainer:

```bash
# Backend development
cd /app  # You're already in the backend workspace
pnpm run start:dev

# PWA development (new terminal)
cd ../pwa
pnpm run dev

# Storybook (new terminal)  
cd ../pwa
pnpm run storybook
```

### Running Tests

```bash
# Backend tests
cd /app
pnpm test

# PWA tests
cd ../pwa
pnpm test
```

### Database Operations

```bash
# Access PostgreSQL
docker exec -it devcontainer_dice_postgres psql -U dice_user -d dice_db

# Check Redis
docker exec -it devcontainer_dice_redis redis-cli
```

### Temporal Workflows

```bash
# Access Temporal CLI
docker exec -it devcontainer_dice_temporal tctl workflow list

# Or use the Web UI at http://localhost:8088
```

## 🔍 Troubleshooting

### Container Won't Start

1. **Check Docker daemon**: Ensure Docker Desktop is running
2. **Check permissions**: Run the setup script again
3. **Clear caches**: Remove old containers and volumes

```bash
docker system prune -a
docker volume prune
```

### Permission Issues

The setup script should handle permissions automatically, but if you encounter issues:

```bash
# Check your user ID
id -u && id -g

# Update the DevContainer .env file manually
# DOCKER_USER=<your-uid>
# DOCKER_GROUP=<your-gid>
```

### Service Connection Issues

```bash
# Check service health
docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}"

# Check logs
docker logs devcontainer_dice_backend
docker logs devcontainer_dice_temporal
```

### Port Conflicts

If ports are already in use on your host:

1. Stop conflicting services
2. Or modify the port mappings in `docker-compose.yml`
3. Update `devcontainer.json` port forwarding accordingly

## 📚 Additional Resources

### Development Guides
- [Backend API Documentation](../workspace/backend/README.md)
- [PWA Development Guide](../workspace/pwa/README.md)
- [Component Library Guide](../workspace/pwa/src/stories/DesignSystem.mdx)

### Service Documentation
- [Services Guide](../SERVICES_GUIDE.md) - Comprehensive service management
- [Temporal Integration](../workspace/backend/src/temporal/README.md)

### Architecture Documentation
- [Project Architecture](../docs/ARCHITECTURE.md)
- [Database Schema](../docs/DATABASE.md)
- [API Documentation](../docs/API.md)

## 🐛 Known Issues

### macOS Specific
- **File watching**: Some file change detection may be slow due to Docker Desktop limitations
- **Performance**: Consider allocating more resources to Docker Desktop

### Windows Specific  
- **Line endings**: Ensure scripts use LF line endings
- **Path mapping**: Windows paths may need adjustment in volume mounts

### Linux Specific
- **User mapping**: Should work seamlessly with proper UID/GID detection

## 🤝 Contributing

When modifying the DevContainer configuration:

1. Test changes with a fresh container build
2. Update this documentation
3. Ensure the setup script handles new requirements
4. Test on multiple platforms if possible

## 📝 Notes

- The DevContainer is optimized for development, not production
- Services use development-friendly configurations (relaxed security, verbose logging)
- Data is persisted in Docker volumes between container restarts
- The backend service uses `sleep infinity` as the command - DevContainer will override this 