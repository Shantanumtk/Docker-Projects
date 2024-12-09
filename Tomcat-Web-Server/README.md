# Tomcat Docker Container Setup and Management Guide

## Prerequisites
- Docker installed on your system
- Basic understanding of Docker and Tomcat
- (Optional) WAR file for web application deployment

## 1. Basic Tomcat Container Deployment

### Quick Start
```bash
# Pull the latest Tomcat image
docker pull tomcat:latest

# Run a basic Tomcat container
docker run --name tomcat-container \
  -d \
  -p 3000:8080 \
  tomcat:latest
```

#### Command Breakdown
- `--name tomcat-container`: Assigns a name to the container
- `-d`: Runs the container in detached mode (background)
- `-p 3000:8080`: Maps Tomcat's internal port 8080 to host port 3000

### Accessing Tomcat Web Interface
- Open web browser: `http://localhost:3000`
- Default Tomcat welcome page should be visible

## 2. Persistent Storage with Docker Volumes

### Create a Named Volume
```bash
# Create a volume for Tomcat webapps
docker volume create tomcat-data
```

### Run Tomcat with Persistent Storage
```bash
docker run --name tomcat-container \
  -d \
  -p 3000:8080 \
  -v tomcat-data:/usr/local/tomcat/webapps \
  tomcat:latest
```

#### Volume Management
```bash
# Inspect volume details
docker volume inspect tomcat-data

# List volumes
docker volume ls

# Remove volume (when no longer needed)
docker volume rm tomcat-data
```

## 3. Custom Tomcat Docker Image

### Dockerfile for Custom Configuration
```dockerfile
# Use official Tomcat image
FROM tomcat:latest

# Optional: Set environment variables
ENV CATALINA_OPTS="-Xms512m -Xmx1024m"

# Copy custom configuration files
COPY ./tomcat-users.xml /usr/local/tomcat/conf/
COPY ./context.xml /usr/local/tomcat/conf/

# Copy web application WAR file
COPY sample.war /usr/local/tomcat/webapps/

# Expose Tomcat port
EXPOSE 8080

# Default command to start Tomcat
CMD ["catalina.sh", "run"]
```

### Build Custom Tomcat Image
```bash
# Build the Docker image
docker build -t custom-tomcat .

# Run the custom Tomcat container
docker run --name custom-tomcat-container \
  -d \
  -p 3000:8080 \
  custom-tomcat
```

## 4. Deploying Web Applications

### Deployment Methods
1. **Volume Mounting**
   ```bash
   docker run -v /local/path/to/webapps:/usr/local/tomcat/webapps \
     -p 3000:8080 tomcat:latest
   ```

2. **Dockerfile COPY**
   ```dockerfile
   COPY your-application.war /usr/local/tomcat/webapps/
   ```

3. **Docker CP Command**
   ```bash
   # Copy WAR file into running container
   docker cp your-application.war tomcat-container:/usr/local/tomcat/webapps/
   ```

### Accessing Deployed Applications
- Web applications will be accessible at `http://localhost:3000/[application-name]`
- Example: `http://localhost:3000/sample`

## 5. Container Management

### Basic Operations
```bash
# List running Tomcat containers
docker ps | grep tomcat

# Stop Tomcat container
docker stop tomcat-container

# Remove Tomcat container
docker rm tomcat-container
```

## 6. Troubleshooting Common Issues

### Checking Logs
```bash
# View container logs
docker logs tomcat-container

# Follow log output in real-time
docker logs -f tomcat-container
```

### Common Debugging Steps
- Verify port mapping
- Check container status
- Inspect container logs
- Ensure WAR file is correctly deployed

## 7. Performance and Security Tips

### Memory Configuration
```dockerfile
# In Dockerfile or docker run
ENV CATALINA_OPTS="-Xms512m -Xmx1024m"
```

### Security Best Practices
- Use minimal Tomcat images
- Limit exposed ports
- Implement authentication
- Regularly update Tomcat image
- Remove default/sample applications

