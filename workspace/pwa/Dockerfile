FROM node:22-bullseye

# Set working directory
WORKDIR /app

# Install system dependencies and pnpm
RUN apt-get update && apt-get install -y \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && npm install -g pnpm@latest

# Set pnpm environment variables
ENV PNPM_HOME=/usr/local/bin
ENV PATH=/usr/local/bin:$PATH

# Create non-root user for security
RUN groupadd -r dice && useradd -r -g dice dice -m
RUN chown -R dice:dice /app

# NOTE: Temporarily running as root for development due to Astro telemetry permission issues
# In production, this should be resolved with proper volume mounts and permissions
# USER dice

# Disable Astro telemetry to avoid permission issues
ENV ASTRO_TELEMETRY_DISABLED=1

# Expose ports
EXPOSE 3000 6006

# Health check with better timeout and retry logic
HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=5 \
  CMD curl -f http://localhost:3000 || exit 1

# Start command (using pnpm for consistency)
CMD ["pnpm", "run", "dev", "--", "--host", "0.0.0.0"] 