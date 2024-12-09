# MongoDB Docker Container Setup and Management Guide

## Prerequisites
- Docker installed on your system
- Basic understanding of Docker and MongoDB

## 1. Running MongoDB with Standard Docker Commands

### Basic MongoDB Container Deployment
```bash
# Pull the latest MongoDB image
docker pull mongo:latest

# Run a basic MongoDB container
docker run --name mongodb-container \
  -e MONGO_INITDB_ROOT_USERNAME=admin \
  -e MONGO_INITDB_ROOT_PASSWORD=admin_password \
  -p 27017:27017 \
  -d mongo:latest
```

#### Environment Variables Explained
- `MONGO_INITDB_ROOT_USERNAME`: Root admin username
- `MONGO_INITDB_ROOT_PASSWORD`: Root admin password
- `-p 27017:27017`: Maps MongoDB's default port to host machine

## 2. Persistent Data Storage with Docker Volumes

### Create a Volume-Backed MongoDB Container
```bash
# Create a named volume for MongoDB data
docker volume create mongodb_data

# Run MongoDB with persistent storage
docker run --name mongodb-container \
  -e MONGO_INITDB_ROOT_USERNAME=admin \
  -e MONGO_INITDB_ROOT_PASSWORD=admin_password \
  -p 27017:27017 \
  -v mongodb_data:/data/db \
  -d mongo:latest
```

#### Benefits of Docker Volumes
- Data persists between container restarts
- Easy backup and migration
- Separates data from container lifecycle

## 3. Creating a Custom MongoDB Docker Image

### Dockerfile for Custom MongoDB Configuration
```dockerfile
# Use official MongoDB image
FROM mongo:latest

# Set environment variables
ENV MONGO_INITDB_ROOT_USERNAME=admin
ENV MONGO_INITDB_ROOT_PASSWORD=admin_password
ENV MONGO_INITDB_DATABASE=mydb

# Copy initialization scripts
COPY ./init-scripts/* /docker-entrypoint-initdb.d/

# Expose MongoDB port
EXPOSE 27017
```

### Initialization Script Example (init-db.js)
```javascript
// Create a new database and collection
db = db.getSiblingDB('mydb');
db.createCollection('users');

// Insert initial data
db.users.insertMany([
  { 
    name: 'John Doe', 
    email: 'john@example.com', 
    age: 30 
  },
  { 
    name: 'Jane Smith', 
    email: 'jane@example.com', 
    age: 25 
  }
]);
```

### Build and Run Custom Image
```bash
# Build the custom MongoDB image
docker build -t custom-mongodb .

# Run the custom container
docker run --name custom-mongodb-container \
  -p 27017:27017 \
  -d custom-mongodb
```

## 4. Interacting with MongoDB Container

### Access MongoDB Shell
```bash
# Interactive MongoDB shell
docker exec -it mongodb-container mongosh \
  -u admin -p admin_password

# Alternative: Use bash to access container
docker exec -it mongodb-container bash
```

### Execute MongoDB Commands
```bash
# Run MongoDB commands directly
docker exec -it mongodb-container mongosh \
  -u admin -p admin_password \
  --eval "db.version()"

# Import JSON/BSON data
docker exec -i mongodb-container mongoimport \
  -u admin -p admin_password \
  --db mydb \
  --collection users \
  --file /path/to/users.json
```

## 5. Container Management

### Basic Container Operations
```bash
# List running MongoDB containers
docker ps | grep mongo

# Stop MongoDB container
docker stop mongodb-container

# Remove MongoDB container
docker rm mongodb-container

# Remove MongoDB volume
docker volume rm mongodb_data
```

## 6. Network Configuration

### Create a Custom Docker Network
```bash
# Create a bridge network
docker network create mongodb-network

# Run MongoDB on custom network
docker run --name mongodb-container \
  --network mongodb-network \
  -d mongo:latest
```

## 7. Security Best Practices

### Recommendations
- Use strong, unique passwords
- Limit network exposure
- Use Docker secrets in production
- Regularly update MongoDB image
- Enable authentication
- Use TLS/SSL for connections

## 8. Troubleshooting

### Debugging Commands
```bash
# View container logs
docker logs mongodb-container

# Inspect container details
docker inspect mongodb-container

# Check container resource usage
docker stats mongodb-container
```

## 9. Connecting External Applications

### Connection String Format
```
mongodb://[username:password@]host:port/[database]

Example:
mongodb://admin:admin_password@localhost:27017/mydb
```

