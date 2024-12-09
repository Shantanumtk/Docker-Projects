# MySQL Docker Container Setup Guide

## Prerequisites
- Docker installed on your system
- Basic understanding of Docker and MySQL

## Basic MySQL Container Deployment

### 1. Pull MySQL Image
```bash
docker pull mysql:latest
```

### 2. Run MySQL Container
```bash
docker run --name mysql-container \
  -e MYSQL_ROOT_PASSWORD=root_password \
  -e MYSQL_DATABASE=testdb \
  -p 3306:3306 \
  -d mysql:latest
```

#### Environment Variables
- `MYSQL_ROOT_PASSWORD`: Sets the root user password
- `MYSQL_DATABASE`: Creates a default database on container startup
- `-p 3306:3306`: Maps container's MySQL port to host machine

## Persistent Data Storage with Docker Volumes

### Creating a Volume-Backed MySQL Container
```bash
docker run --name mysql-container \
  -e MYSQL_ROOT_PASSWORD=root_password \
  -e MYSQL_DATABASE=testdb \
  -p 3306:3306 \
  -v mysql_data:/var/lib/mysql \
  -d mysql:latest
```

#### Benefits of Using Volumes
- Data persists even if container is removed
- Easy backup and migration
- Separates data from container lifecycle

## Creating a Custom MySQL Docker Image

### Step 1: Create a Dockerfile
```dockerfile
# Use the official MySQL image as the base image
FROM mysql:latest

# Set environment variables for MySQL root password, database name, and user credentials
ENV MYSQL_ROOT_PASSWORD=root_password
ENV MYSQL_DATABASE=sample_db
ENV MYSQL_USER=user
ENV MYSQL_PASSWORD=user_password

# Copy the SQL scripts into the container (optional for initialization)
COPY ./init.sql /docker-entrypoint-initdb.d/

# Expose MySQL port
EXPOSE 3306
```

#### Dockerfile Breakdown
- **Base Image**: Uses the official `mysql:latest` image
- **Environment Variables**:
  - `MYSQL_ROOT_PASSWORD`: Password for the root user
  - `MYSQL_DATABASE`: Optional database to create at startup
  - `MYSQL_USER` and `MYSQL_PASSWORD`: Create a new user with these credentials
- **Initialization Script**: Any `.sql` or `.sh` files in `/docker-entrypoint-initdb.d/` will be executed on container startup

### Step 2: Create Initialization Script (Optional)
Create an `init.sql` file to initialize the database:
```sql
CREATE TABLE IF NOT EXISTS employees (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    position VARCHAR(50),
    salary DECIMAL(10, 2)
);

INSERT INTO employees (name, position, salary)
VALUES 
    ('John Doe', 'Manager', 75000.00),
    ('Jane Smith', 'Developer', 60000.00);
```

### Step 3: Build the Docker Image
```bash
docker build -t custom-mysql-container .
```
This creates a new Docker image named `custom-mysql`.

### Step 4: Run the Custom Container
```bash
docker run --name mysql-container -d -p 3306:3306 custom-mysql-container
```
- `--name mysql-container`: Assigns a name to the container
- `-d`: Runs the container in detached mode
- `-p 3306:3306`: Maps MySQL's default port to the host

## Interacting with MySQL Container

### 1. Access MySQL Shell
```bash
# Interactive shell
docker exec -it mysql-container mysql -u root -proot_password

# Alternative with prompt for password
docker exec -it mysql-container mysql -u root -p
```

### 2. Execute SQL Scripts
```bash
# Run SQL script from local machine
docker exec -i mysql-container mysql -u root -proot_password < your_script.sql

# Run SQL script without password (will prompt)
docker exec -i mysql-container mysql -u root < your_script.sql
```

### 3. Connecting with External Tools
- **Host**: `localhost`
- **Port**: `3306`
- **Username**: `root` or custom user defined in Dockerfile
- **Password**: Password defined in Dockerfile or during container run

## Managing the Container

### Stop Container
```bash
docker stop mysql-container
```

### Remove Container
```bash
docker rm mysql-container
```

### List Volumes
```bash
docker volume ls
```

### Remove Volume
```bash
docker volume rm mysql_data
```

## Security Recommendations
- Use strong, unique passwords
- Limit port exposure
- Regularly update MySQL image
- Use Docker secrets for sensitive information in production
- Avoid hardcoding passwords in Dockerfiles for production environments

## Troubleshooting
- Check container logs: `docker logs mysql-container`
- Verify container status: `docker ps`
- Inspect container details: `docker inspect mysql-container`

## Additional Configuration
Customize MySQL configuration by mounting a `my.cnf` file:
```bash
docker run --name mysql-container \
  -v /path/to/my.cnf:/etc/mysql/my.cnf \
  ... # other configurations
```



