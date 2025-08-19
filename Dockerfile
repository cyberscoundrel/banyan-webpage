# Multi-stage build for Banyan Documentation Website
# Stage 1: Build the application
FROM node:18-alpine AS builder

# Install git for cloning the repository
RUN apk add --no-cache git

# Set working directory
WORKDIR /app

# Clone the repository
ARG GITHUB_REPO
ARG GITHUB_BRANCH=main
RUN if [ -z "$GITHUB_REPO" ]; then \
        echo "Error: GITHUB_REPO build argument is required"; \
        exit 1; \
    fi && \
    git clone --depth 1 --branch ${GITHUB_BRANCH} https://github.com/${GITHUB_REPO}.git . && \
    rm -rf .git

# Install dependencies
RUN npm ci --only=production=false

# Build the application for production
RUN npm run build

# Stage 2: Serve the application with nginx
FROM nginx:alpine AS production

# Copy built files from builder stage
COPY --from=builder /app/dist /usr/share/nginx/html

# Copy nginx configuration for SPA routing
COPY <<EOF /etc/nginx/conf.d/default.conf
server {
    listen 80;
    server_name localhost;
    root /usr/share/nginx/html;
    index index.html;

    # Handle client-side routing
    location / {
        try_files \$uri \$uri/ /index.html;
    }

    # Cache static assets
    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }

    # Security headers
    add_header X-Frame-Options "SAMEORIGIN" always;
    add_header X-Content-Type-Options "nosniff" always;
    add_header X-XSS-Protection "1; mode=block" always;
    add_header Referrer-Policy "strict-origin-when-cross-origin" always;

    # Gzip compression
    gzip on;
    gzip_vary on;
    gzip_min_length 1024;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
}
EOF

# Expose port 80
EXPOSE 80

# Start nginx
CMD ["nginx", "-g", "daemon off;"]
