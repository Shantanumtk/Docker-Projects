# Complete PostgreSQL Docker Container Guide

## Table of Contents
- [Basic Setup Methods](#basic-setup-methods)
  - [Method 1: Using Standard Docker Commands](#method-1-using-standard-docker-commands)
  - [Method 2: Using Custom Dockerfile](#method-2-using-custom-dockerfile)
- [Volume Management](#volume-management)
- [Security Best Practices](#security-best-practices)
- [Troubleshooting](#troubleshooting)

## Basic Setup Methods

### Method 1: Using Standard Docker Commands

#### 1. Pull the PostgreSQL Image
```bash
docker pull postgres:15
```

#### 2. Run PostgreSQL Container
```bash
docker run --name postgres15-container \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=admin123 \
  -e POSTGRES_DB=mydb \
  -p 5433:5432 \
  -d postgres:15
```

Parameters explained:
- `--name postgres15-container`: Container name
- `-e POSTGRES_USER=admin`: Database username
- `-e POSTGRES_PASSWORD=admin123`: Database password
- `-e POSTGRES_DB=mydb`: Default database name
- `-p 5433:5432`: Port mapping
- `-d`: Detached mode

#### 3. Verify Container
```bash
docker ps
```

#### 4. Connect to Database
```bash
psql -h localhost -p 5433 -U admin -d mydb
```

#### 5. Stop Container
```bash
docker stop postgres15-container
```

### Method 2: Using Custom Dockerfile

#### 1. Create Dockerfile
```dockerfile
# Use the PostgreSQL 15 base image
FROM postgres:15

# Install additional packages (optional)
RUN apt-get update && apt-get install -y \
    procps \
    openssh-server \
    openssh-client \
    vim \
    iputils-ping \
    && rm -rf /var/lib/apt/lists/*

# Copy initialization scripts
COPY init.sql /docker-entrypoint-initdb.d/
```

#### 2. Create init.sql (Optional)
```sql
CREATE TABLE example_table (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL
);

INSERT INTO example_table (name) VALUES ('Sample Data');
```

#### 3. Build Image
```bash
docker build -t custom-postgres15 .
```

#### 4. Run Container
```bash
docker run -d \
  -e POSTGRES_PASSWORD=admin123 \
  -e POSTGRES_USER=admin \
  -e POSTGRES_DB=mydb \
  -p 5433:5432 \
  --name postgres-db-container \
  custom-postgres15
```

## Volume Management

### 1. Named Volumes Setup
```bash
# Create volume
docker volume create postgres_data

# Run with volume
docker run -d \
  -e POSTGRES_PASSWORD=admin123 \
  -e POSTGRES_USER=admin \
  -e POSTGRES_DB=mydb \
  -p 5433:5432 \
  -v postgres_data:/var/lib/postgresql/data \
  --name postgres-db-container \
  custom-postgres15
```

### 2. Docker Compose Setup
```yaml
version: '3.8'
services:
  postgres:
    build: .
    container_name: postgres-db-container
    environment:
      POSTGRES_USER: admin
      POSTGRES_PASSWORD: admin123
      POSTGRES_DB: mydb
    ports:
      - "5433:5432"
    volumes:
      - postgres_data:/var/lib/postgresql/data
    networks:
      - postgres-network

volumes:
  postgres_data:
    name: postgres_data

networks:
  postgres-network:
    driver: bridge
```

### 3. Volume Management Commands
```bash
# List volumes
docker volume ls

# Inspect volume
docker volume inspect postgres_data

# Remove volume
docker volume rm postgres_data

# Clean unused volumes
docker volume prune
```

### 4. Backup and Restore
```bash
# Backup
docker exec postgres-db-container \
  pg_dump -U admin mydb > backup.sql

# Restore
cat backup.sql | docker exec -i postgres-db-container \
  psql -U admin -d mydb
```

## Security Best Practices

1. **Credential Management**
   - Use environment variables
   - Never store passwords in Dockerfile
   - Use Docker secrets in production

2. **Network Security**
   - Use custom networks
   - Limit port exposure
   - Enable SSL/TLS

3. **Volume Security**
   - Set proper permissions
   - Regular backups
   - Encrypt sensitive data

## Troubleshooting

### Common Issues

1. **Connection Problems**
```bash
# Check logs
docker logs postgres-db-container

# Check container status
docker ps

# Verify port mapping
docker port postgres-db-container
```

2. **Volume Issues**
```bash
# Check permissions
docker exec postgres-db-container ls -la /var/lib/postgresql/data

# Verify mounts
docker inspect postgres-db-container | grep -A 10 Mounts
```

3. **Database Issues**
```bash
# Check PostgreSQL logs
docker exec postgres-db-container cat /var/log/postgresql/postgresql-*.log
```

### Maintenance Commands

```bash
# Stop container
docker stop postgres-db-container

# Remove container
docker rm postgres-db-container

# Remove image
docker rmi custom-postgres15
```

## Additional Notes

1. For production environments:
   - Use strong passwords
   - Regular backups
   - Monitor resource usage
   - Keep PostgreSQL updated

2. Development tips:
   - Use bind mounts for quick development
   - Enable PostgreSQL logging
   - Use pgAdmin or similar tools for management

Remember to adjust usernames, passwords, and ports according to your needs. Never use default credentials in production environments.
