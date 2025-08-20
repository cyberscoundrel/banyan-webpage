# Dockerfile for Banyan Documentation Website using serve package
FROM node:18-alpine

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
RUN npm ci

# Build the application for production
RUN npm run build

# Install serve globally
RUN npm install -g serve

# Expose serve port
EXPOSE 3000

# Serve the built application
CMD ["serve", "-s", "dist", "-l", "3000"]
