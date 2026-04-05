# VedantaTrade Production Dockerfile
# Multi-stage build for optimal image size and security

# Base stage - Flutter dependencies
FROM dart:stable AS flutter-base
WORKDIR /app

# Install Flutter
RUN wget -qO- https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.19.0-stable.tar.xz | tar -xJ -C /opt/
ENV PATH="/opt/flutter/bin:$PATH"

# Install dependencies for Flutter web build
RUN apt-get update && apt-get install -y \
    curl \
    git \
    unzip \
    xz-utils \
    zip \
    libglu1-mesa \
    libgtk-3-0 \
    libx11-6 \
    && rm -rf /var/lib/apt/lists/*

# Build stage - Flutter web application
FROM flutter-base AS build-stage
WORKDIR /app

# Copy source code
COPY . .

# Install Flutter dependencies
RUN flutter pub get

# Download Flutter web dependencies
RUN flutter pub run build_runner build --delete-conflicting-outputs

# Build Flutter web application
RUN flutter build web --release --web-renderer canvaskit --no-tree-shake-icons

# Production stage - Nginx server
FROM nginx:alpine AS production-stage

# Install additional packages for monitoring and security
RUN apk add --no-cache \
    curl \
    jq \
    tzdata \
    && rm -rf /var/cache/apk/*

# Copy custom Nginx configuration
COPY deployment/docker/nginx.conf /etc/nginx/nginx.conf
COPY deployment/docker/default.conf /etc/nginx/conf.d/default.conf

# Copy Flutter web build
COPY --from=build-stage /app/build/web /usr/share/nginx/html

# Copy health check script
COPY deployment/docker/health-check.sh /usr/local/bin/health-check.sh
RUN chmod +x /usr/local/bin/health-check.sh

# Copy monitoring scripts
COPY deployment/docker/monitor.sh /usr/local/bin/monitor.sh
RUN chmod +x /usr/local/bin/monitor.sh

# Create non-root user for security
RUN addgroup -g 1001 -S nginx && \
    adduser -S nginx -u 1001 -G nginx

# Set proper permissions
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chown -R nginx:nginx /var/cache/nginx && \
    chown -R nginx:nginx /var/log/nginx && \
    chown -R nginx:nginx /etc/nginx/conf.d

# Create nginx runtime directories
RUN touch /var/run/nginx.pid && \
    chown -R nginx:nginx /var/run/nginx.pid

# Switch to non-root user
USER nginx

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD /usr/local/bin/health-check.sh

# Start Nginx
CMD ["nginx", "-g", "daemon off;"]
