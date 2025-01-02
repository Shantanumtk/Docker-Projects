# Node.js MySQL CRUD API with Docker

A RESTful CRUD API built with Node.js, Express, and MySQL, containerized using Docker.

## Table of Contents
- [Features](#features)
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Installation & Setup](#installation--setup)
- [API Endpoints](#api-endpoints)
- [Docker Commands](#docker-commands)
- [Environment Variables](#environment-variables)
- [Error Handling](#error-handling)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)

## Features
- RESTful API endpoints for CRUD operations
- MySQL database with automatic initialization
- Docker containerization
- Environment variable configuration
- Error handling
- CORS enabled
- Connection pooling
- Request validation

## Prerequisites
- Node.js (v14 or higher)
- Docker
- MySQL 8.0
- npm or yarn package manager
- postman (for testing)

## Project Structure
```
project-root/
├── config/
│   └── db.js                     # Database configuration
├── routes/
│   └── users.js                  # User routes
├── docker-entrypoint-initdb.d/   # MySQL initialization scripts
│   └── init.sql                  # Database setup script
├── .env                          # Environment variables
├── .gitignore                    # Git ignore file
├── Dockerfile                    # Node.js Dockerfile
├── index.js                      # Application entry point
├── package.json                  # Project dependencies
└── README.md                     # Project documentation
```

## Installation & Setup

### 1. Clone the repository
```bash
git clone <repository-url>
cd <project-directory>
```

### 2. Create Docker Network
```bash
docker network create my-network
```

### 3. Start MySQL Container
```bash
docker run --name mysql-container \
  --network my-network \
  -e MYSQL_ROOT_PASSWORD=rootpassword \
  -e MYSQL_DATABASE=crud_db \
  -e MYSQL_USER=user \
  -e MYSQL_PASSWORD=password \
  -v ./docker-entrypoint-initdb.d/init.sql:/docker-entrypoint-initdb.d/init.sql \
  -p 3306:3306 \
  -d mysql:8.0
```

### 4. Create Database Table
```bash
docker exec -it mysql-container mysql -uuser -ppassword crud_db -e "
CREATE TABLE users (
  id INT AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  email VARCHAR(255) NOT NULL UNIQUE,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);"
```

## Database Management

### Accessing MySQL Container

1. Login to Container Shell:
```bash
docker exec -it mysql-container bash
```

2. Connect to MySQL:
```bash
# Direct database connection
mysql -u user -p crud_db

# Or connect with root user
mysql -u root -p
```

3. Common MySQL Commands:
```sql
-- Show all databases
SHOW DATABASES;

-- Use specific database
USE crud_db;

-- Show all tables
SHOW TABLES;

-- Describe table structure
DESCRIBE users;
DESCRIBE products;

-- Query data
SELECT * FROM users;
SELECT * FROM products;
```

### Database Backup and Restore

1. Export Database:
```bash
docker exec mysql-container mysqldump -u user -p crud_db > backup.sql
```

2. Import Database:
```bash
docker exec -i mysql-container mysql -u user -p crud_db < backup.sql
```

### 5. Build and Run Node.js Container
```bash
# Build the image
docker build -t nodejs-api .

# Run the container
docker run --name nodejs-container \
  --network my-network \
  -p 3000:3000 \
  -d nodejs-api
```

## API Endpoints

### Users
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET    | /api/users | Get all users |
| GET    | /api/users/:id | Get a specific user |
| POST   | /api/users | Create a new user |
| PUT    | /api/users/:id | Update a user |
| DELETE | /api/users/:id | Delete a user |

### Request & Response Examples

#### Create User
```bash
# Request
curl -X POST http://localhost:3000/api/users \
-H "Content-Type: application/json" \
-d '{
  "name": "John Doe",
  "email": "john@example.com"
}'

# Response
{
  "message": "User created successfully",
  "id": 1
}
```

#### Get All Users
```bash
# Request
curl http://localhost:3000/api/users

# Response
[
  {
    "id": 1,
    "name": "John Doe",
    "email": "john@example.com",
    "created_at": "2025-01-01T12:00:00.000Z"
  }
]
```

## Docker Commands

### Container Management
```bash
# View running containers
docker ps

# View all containers
docker ps -a

# Stop containers
docker stop nodejs-container mysql-container

# Remove containers
docker rm nodejs-container mysql-container

# Remove network
docker network rm my-network
```

### Logs and Debugging
```bash
# View container logs
docker logs nodejs-container
docker logs mysql-container

# Enter container shell
docker exec -it nodejs-container /bin/bash
docker exec -it mysql-container /bin/bash
```

## Environment Variables
Create a `.env` file in the root directory:
```
PORT=3000
DB_HOST=mysql-container
DB_USER=user
DB_PASSWORD=password
DB_NAME=crud_db
```

## Error Handling
The API implements the following error handling:
- Database connection errors
- Invalid request data
- Resource not found (404)
- Server errors (500)
- Duplicate entry errors
- Validation errors

## Testing
You can test the API using Postman or curl commands:

1. Import the following Postman collection:
```json
{
  "info": {
    "name": "Node.js MySQL API"
  },
  "item": [
    {
      "name": "Get Users",
      "request": {
        "method": "GET",
        "url": "http://localhost:3000/api/users"
      }
    },
    {
      "name": "Create User",
      "request": {
        "method": "POST",
        "url": "http://localhost:3000/api/users",
        "body": {
          "mode": "raw",
          "raw": "{\"name\": \"John Doe\", \"email\": \"john@example.com\"}",
          "options": {
            "raw": {
              "language": "json"
            }
          }
        }
      }
    }
  ]
}
```

## Troubleshooting

### Common Issues

1. Container Connection Issues
```bash
# Check if containers are running
docker ps

# Check container networks
docker network inspect my-network

# Restart containers
docker restart nodejs-container mysql-container
```

2. Database Connection Issues
```bash
# Check MySQL logs
docker logs mysql-container

# Verify MySQL connection
docker exec -it mysql-container mysql -uuser -ppassword -e "SELECT 1"
```

3. Node.js Application Issues
```bash
# Check application logs
docker logs nodejs-container

# Verify application environment
docker exec -it nodejs-container env
```
