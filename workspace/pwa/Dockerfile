FROM node:22-bullseye

# Set working directory
WORKDIR /app

# Install system dependencies and pnpm
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && npm install -g pnpm@latest

# Note: package.json, config files, and source files are provided via volume mount in development
# Dependencies will be installed in the node_modules volume to avoid conflicts

# Create non-root user for security
RUN groupadd -r dice && useradd -r -g dice dice -m
RUN chown -R dice:dice /app

# NOTE: Temporarily running as root for development due to Astro telemetry permission issues
# In production, this should be resolved with proper volume mounts and permissions
# USER dice

# Disable Astro telemetry to avoid permission issues
ENV ASTRO_TELEMETRY_DISABLED=1

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000 || exit 1

# Start command (using pnpm for consistency)
CMD ["pnpm", "run", "dev", "--", "--host", "0.0.0.0"] 