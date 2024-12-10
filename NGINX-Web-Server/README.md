# Custom NGINX Docker Web Server

## Project Overview
A custom Docker container setup for an NGINX web server with a simple HTML page and custom configuration.

## Project Structure
```
nginx-docker-project/
│
├── Dockerfile
├── nginx.conf
├── index.html
└── README.md
```

## Prerequisites
- Docker (version 20.10 or higher)
- Basic understanding of Docker and NGINX

## Dockerfile Breakdown
```dockerfile
# Use the official Nginx image as the base image
FROM nginx:latest

# Copy custom configuration file to Nginx directory
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy the custom HTML content to the Nginx default root directory
COPY index.html /usr/share/nginx/html/index.html

# Expose port 80
EXPOSE 80
```

## Docker Commands

### Build the Docker Image
```bash
# Build the custom NGINX image
docker build -t custom-nginx .
```

### Run Container Variations

#### Basic Run (Mapping to port 3000)
```bash
# Run the container and map port 3000
docker run -d -p 3000:80 --name custom-nginx-container custom-nginx
```

#### Volume Mount (For Dynamic Content)
```bash
# Mount local html directory to container
docker run -d -p 8080:80 -v $(pwd)/html:/usr/share/nginx/html custom-nginx
```

### Container Management
```bash
# View container logs
docker logs custom-nginx-container

# Inspect configuration file
docker exec -it custom-nginx-container cat /etc/nginx/conf.d/default.conf
```

## NGINX Configuration Details
```nginx
server {
    listen 80;
    server_name localhost;
    
    location / {
        root /usr/share/nginx/html;
        index index.html;
    }
    
    error_page 404 /404.html;
    location = /404.html {
        root /usr/share/nginx/html;
    }
}
```

## Key Features
- Custom NGINX configuration
- Simple HTML landing page
- Flexible port mapping
- Volume mounting support
- Easy container management

## Advanced Configuration Options

### Adding SSL/TLS
- Mount SSL certificates
- Update NGINX configuration for HTTPS
- Use Let's Encrypt for free SSL certificates

### Performance Optimization
- Enable gzip compression
- Configure caching headers
- Implement client-side caching

## Sample index.html
```html
<!DOCTYPE html>
<html>
<head>
    <title>Custom Nginx Container</title>
</head>
<body>
    <h1>Welcome to the Custom Nginx Server!</h1>
    <p>This is served from a custom Docker container.</p>
</body>
</html>
```

## Troubleshooting

### Common Issues
- Port conflicts
- Permission problems
- Configuration syntax errors

### Debugging Steps
1. Check Docker logs
2. Verify configuration files
3. Ensure proper file permissions
4. Validate Docker image build

## Best Practices
- Use specific NGINX image tags
- Minimize container size
- Implement health checks
- Use multi-stage builds for production

## Recommended .dockerignore
```
.git
.env
node_modules
*.log
```

## Environment Variables
- `NGINX_HOST`: Custom server name
- `NGINX_PORT`: Alternative port configuration
