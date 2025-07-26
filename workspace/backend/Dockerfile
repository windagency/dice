FROM node:22-bullseye

# Set working directory
WORKDIR /app

# Install system dependencies and pnpm
RUN apt-get update && apt-get install -y \
    postgresql-client \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && npm install -g pnpm@latest

# Note: package.json, tsconfig.json, and source files are provided via volume mount in development
# Dependencies will be installed in the node_modules volume to avoid conflicts

# Create non-root user for security
RUN groupadd -r dice && useradd -r -g dice dice
RUN chown -R dice:dice /app

# Switch to non-root user
USER dice

# Expose ports
EXPOSE 3001 9229

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3001/health || exit 1

# Start command (using pnpm for consistency)
CMD ["pnpm", "run", "start:dev"] 