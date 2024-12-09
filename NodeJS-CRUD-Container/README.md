# Node.js Docker Application 

## Project Structure
```
project-root/
│
├── Dockerfile                # Single-stage Dockerfile
├── Dockerfile.multistage     # Multi-stage Dockerfile
├── package.json
├── package-lock.json
├── src/
├── tests/
└── README.md
```

## Dockerfiles

### Single-Stage Dockerfile
```dockerfile
# Use the official Node.js image as the base
FROM node:18

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json to the container
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code to the container
COPY . .

# Run tests
RUN npm test

# Expose the application's port
EXPOSE 3000

# Command to run the application
CMD ["npm", "start"]
```

### Multi-Stage Dockerfile
```dockerfile
# Stage 1: Install dependencies and run tests
FROM node:18 AS build-and-test-stage
# Set working directory
WORKDIR /usr/src/app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code
COPY . .

# Run tests
RUN npm test --exit

# Stage 2: Create minimal runtime image
FROM node:18-alpine AS runtime-stage
# Set working directory
WORKDIR /usr/src/app

# Copy only necessary files from the previous stage
COPY --from=build-and-test-stage /usr/src/app/package*.json ./
COPY --from=build-and-test-stage /usr/src/app/node_modules ./node_modules
COPY --from=build-and-test-stage /usr/src/app/. .

# Expose the application port
EXPOSE 3000

# Run the application
CMD ["npm", "start"]
```

## Docker Commands

### Single-Stage Docker Workflow
```bash
# Build the Docker image
docker build -t node-rest-app .

# Run tests in the container
docker run --rm node-rest-app npm test

# Start the application
docker run -d -p 3000:3000 --name node-rest-app-container node-rest-app
```

### Multi-Stage Docker Workflow
```bash
# Build the multi-stage Docker image
docker build -f Dockerfile.multistage -t my-app-build .

# Run tests
docker run --rm my-app-build npm test

# Start the application
docker run -d --name rest-api-server -p 3000:3000 my-app-build
```

## Prerequisites
- Docker 20.10 or higher
- Node.js 18.x
- npm 8.x or higher

## Key Differences Between Dockerfiles

### Single-Stage Dockerfile
- Simple, straightforward approach
- Entire build process in one stage
- Larger image size
- Includes all build tools and dependencies in the final image

### Multi-Stage Dockerfile
- Separates build and runtime environments
- Significantly smaller final image size
- Runs tests during build process
- Uses Alpine Linux for lightweight runtime image
- Removes unnecessary build tools from final image

## Performance and Size Comparison
| Aspect | Single-Stage | Multi-Stage |
|--------|--------------|-------------|
| Image Size | Larger (often 1GB+) | Smaller (typically 100-300MB) |
| Build Time | Faster initial build | Slightly longer due to two stages |
| Test Integration | Tests run in same stage | Tests run in first stage |
| Runtime Efficiency | Good | Excellent |

## Best Practices
1. Always use specific version tags for base images
2. Minimize the number of layers
3. Use .dockerignore to exclude unnecessary files
4. Run tests as part of the build process
5. Avoid running containers as root user

## Recommended .dockerignore
```
node_modules
npm-debug.log
Dockerfile*
docker-compose*
.dockerignore
.git
.gitignore
README.md
```

## Troubleshooting
- Ensure all dependencies are listed in package.json
- Check that npm scripts (test, start) are correctly defined
- Verify port mappings
- Review Docker and application logs for any issues

## Security Recommendations
- Use `npm audit` to check for vulnerabilities
- Regularly update base images and dependencies
- Consider adding a non-root user in Dockerfile
- Implement least privilege principles


