FROM node:22-bullseye

# Set working directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Create package.json for initial setup if not present
COPY package*.json ./
RUN if [ ! -f package.json ]; then \
    echo '{ "name": "dice-pwa", "version": "1.0.0", "scripts": { "dev": "echo \"PWA starting...\"", "build": "echo \"PWA building...\"" } }' > package.json; \
fi

# Copy configuration files if present
COPY astro.config* ./ || true
COPY tsconfig*.json ./ || true

# Install dependencies or create minimal setup
RUN if [ -f package-lock.json ]; then \
    npm ci && npm cache clean --force; \
else \
    npm init -y && \
    npm install --save astro @astrojs/react react react-dom @astrojs/tailwind tailwindcss typescript @types/node @types/react @types/react-dom; \
fi

# Copy source code if present
COPY src* ./src/ || true
COPY public* ./public/ || true

# Create basic project structure if not present
RUN if [ ! -d src ]; then \
    mkdir -p src/pages src/components public && \
    echo '<html><head><title>DICE PWA</title></head><body><h1>DICE Character Manager PWA</h1><p>Loading...</p></body></html>' > src/pages/index.astro && \
    echo 'import { defineConfig } from "astro/config"; export default defineConfig({ server: { host: "0.0.0.0", port: 3000 } });' > astro.config.mjs; \
fi

# Create non-root user
RUN groupadd -r dice && useradd -r -g dice dice
RUN chown -R dice:dice /app
USER dice

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000 || exit 1

# Start command
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"] 