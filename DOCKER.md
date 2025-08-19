# Docker Setup for Banyan Documentation Website

This project includes Docker configuration for production deployment with nginx and optional development setup.

## Quick Start

### Production Build with GitHub Repository

The main `Dockerfile` builds your project from GitHub for production deployment:

```bash
# Build the Docker image (replace with your GitHub repo)
docker build --build-arg GITHUB_REPO="your-username/your-repo-name" -t banyan-webpage .

# Run the container
docker run -p 8080:80 banyan-webpage
```

### Using Docker Compose

The easiest way to get started is with docker-compose:

```bash
# Edit docker-compose.yml and update the GITHUB_REPO argument
# Then build and run for production
docker-compose up --build
```

Visit `http://localhost:8080` to see your documentation site.

## Configuration Options

### Build Arguments

- `GITHUB_REPO` (required): Your GitHub repository in format `username/repository-name`
- `GITHUB_BRANCH` (optional): Git branch to clone (defaults to `main`)

### Examples

```bash
# Build from main branch
docker build --build-arg GITHUB_REPO="myusername/banyan-webpage" -t banyan-webpage .

# Build from specific branch
docker build \
  --build-arg GITHUB_REPO="myusername/banyan-webpage" \
  --build-arg GITHUB_BRANCH="develop" \
  -t banyan-webpage .
```

## Development vs Production

### Production Mode (Default)
The main `Dockerfile` and `Dockerfile.local` build optimized production bundles:

```bash
# Production build with local files
docker build -f Dockerfile.local -t banyan-webpage-local .
docker run -p 8080:80 banyan-webpage-local
```

### Development Mode  
For active development with hot reload, use the development Dockerfile:

```bash
# Development with webpack dev server
docker build -f Dockerfile.dev -t banyan-webpage-dev .
docker run -p 3000:3000 banyan-webpage-dev

# Or with docker-compose
docker-compose --profile dev up --build
```

## Production Features

The production Docker setup provides:

- Multi-stage builds for minimal image size
- Nginx serving optimized static files
- Proper SPA routing configuration
- Security headers
- Gzip compression
- Static asset caching (1 year)
- Production webpack optimizations

### Environment Variables

No environment variables are required for basic operation.

### Volumes

The container serves static files and doesn't require persistent volumes.

### Health Checks

You can add a health check to your docker-compose.yml:

```yaml
services:
  banyan-webpage:
    # ... other configuration
    healthcheck:
      test: ["CMD", "wget", "--quiet", "--tries=1", "--spider", "http://localhost/"]
      interval: 30s
      timeout: 10s
      retries: 3
      start_period: 40s
```

## File Structure

- `Dockerfile` - Production build with GitHub repository cloning
- `Dockerfile.local` - Production build with local files  
- `Dockerfile.dev` - Development build with webpack dev server
- `docker-compose.yml` - Docker Compose configuration with production and dev profiles
- `.dockerignore` - Files to exclude from Docker build context

## Troubleshooting

### Common Issues

1. **Build fails with git clone error**
   - Ensure the GitHub repository URL is correct
   - Check if the repository is public or if you need authentication

2. **Port already in use**
   - For production: Change the port mapping: `-p 8081:80` instead of `-p 8080:80`
   - For development: Change the port mapping: `-p 3001:3000` instead of `-p 3000:3000`

3. **Build context too large**
   - Ensure `.dockerignore` is properly configured
   - Remove unnecessary files from the project directory

### Debug Commands

```bash
# Build with verbose output
docker build --no-cache --progress=plain --build-arg GITHUB_REPO="username/repo" .

# Run with interactive shell for debugging
docker run -it --entrypoint /bin/sh banyan-webpage

# Check container logs (nginx for production, webpack for dev)
docker logs <container-id>
```

## Private Repositories

For private GitHub repositories, you'll need to modify the Dockerfile to include authentication. Consider using:

- GitHub Personal Access Tokens
- SSH keys
- Docker secrets

Example with PAT:
```dockerfile
ARG GITHUB_TOKEN
RUN git clone https://${GITHUB_TOKEN}@github.com/${GITHUB_REPO}.git .
```

## Optimization Features

### Production Optimizations:
- Multi-stage builds minimize final image size (~15-25MB)
- Layer caching for npm dependencies
- Minimal Alpine Linux base images
- Nginx with gzip compression and caching
- Production webpack optimizations (minification, tree-shaking)
- Security headers

### Development Features:
- Webpack dev server with hot module replacement
- Fast development builds
- Source maps enabled for debugging
- Live reloading on file changes
