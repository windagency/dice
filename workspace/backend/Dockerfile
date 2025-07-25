FROM node:22-bullseye

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    postgresql-client \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create package.json for initial setup if not present
COPY package*.json ./
RUN if [ ! -f package.json ]; then \
    echo '{ "name": "dice-backend", "version": "1.0.0", "scripts": { "start": "echo \"Backend starting...\"", "start:dev": "echo \"Backend dev mode...\"" } }' > package.json; \
fi

# Install dependencies or create minimal setup
RUN if [ -f package-lock.json ]; then \
    npm ci --only=production && npm cache clean --force; \
else \
    npm init -y && \
    npm install --save @nestjs/core @nestjs/common @nestjs/platform-express typescript @types/node; \
fi

# Copy source code if present
COPY src* ./src/ || true
COPY tsconfig*.json ./ || true

# Create basic src structure if not present
RUN if [ ! -d src ]; then \
    mkdir -p src && \
    echo 'console.log("DICE Backend Service Starting...");' > src/main.ts; \
fi

# Create non-root user
RUN groupadd -r dice && useradd -r -g dice dice
RUN chown -R dice:dice /app
USER dice

# Expose ports
EXPOSE 3001 9229

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3001/health || exit 1

# Start command
CMD ["npm", "run", "start:dev"] 