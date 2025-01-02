# Node.js PostgreSQL CRUD API with Docker

A robust REST API implementation featuring a Node.js backend with PostgreSQL database, fully containerized using Docker. The API provides complete CRUD (Create, Read, Update, Delete) operations for managing user data.

## Features

- RESTful API endpoints for user management
- PostgreSQL database for persistent storage
- Docker containerization for both Node.js and PostgreSQL
- Environment-based configuration
- Structured project organization
- Error handling and proper HTTP status codes

## Prerequisites

Before you begin, ensure you have installed:
- Docker and Docker Compose
- Node.js (for local development)
- curl or Postman (for testing)

## Project Structure

```
project-root/
├── config/
│   └── db.js                     # Database configuration
├── routes/
│   └── users.js                  # User routes
├── docker-entrypoint-initdb.d/   # PostgreSQL initialization scripts
│   └── init.sql                  # Database setup script
├── .env                          # Environment variables
├── .gitignore                    # Git ignore file
├── Dockerfile                    # Node.js Dockerfile
├── index.js                      # Application entry point
├── package.json                  # Project dependencies
└── README.md                     # Project documentation
```

## Database Setup

### Database Initialization Script (init.sql)

Create a file named `init.sql` in the `docker-entrypoint-initdb.d` directory:

```sql
CREATE DATABASE node_crud_db;
\c node_crud;

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(100)
);

INSERT INTO users (name, email) VALUES
('Ethan Hunt', 'ethan.hunt@example.com'),
('Tom Cruise', 'tom.cruise@example.com');
```

This script will:
1. Create the database
2. Create the users table
3. Insert initial sample data

## Environment Configuration

Create a `.env` file in the root directory with the following configurations:

```plaintext
DB_USER=admin
DB_PASSWORD=adminpassword
DB_NAME=node_crud
DB_HOST=postgres-container
DB_PORT=5432
NODE_ENV=development
PORT=3000
```

## Quick Start

1. Clone the repository:
```bash
git clone <repository-url>
cd <project-directory>
```

2. Create and configure the Docker network:
```bash
docker network create node-postgres-network
```

3. Start the PostgreSQL container:
```bash
docker run --name postgres-container \
  --network node-postgres-network \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=adminpassword \
  -e POSTGRES_DB=node_crud \
  -v ./docker-entrypoint-initdb.d:/docker-entrypoint-initdb.d \
  -p 5432:5432 \
  -d postgres:15
```

4. Build and run the Node.js application:
```bash
docker build -t node-app .
docker run --name node-container \
  --network node-postgres-network \
  -p 3000:3000 \
  -d node-app
```

## API Endpoints

### Users

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET    | /users   | Retrieve all users |
| POST   | /users   | Create a new user |
| PUT    | /users/:id | Update a user by ID |
| DELETE | /users/:id | Delete a user by ID |

### Example API Requests

#### Get all users
```bash
curl http://localhost:3000/users
```

#### Create a new user
```bash
curl -X POST http://localhost:3000/users \
-H "Content-Type: application/json" \
-d '{"name": "Alice", "email": "alice@example.com"}'
```

#### Update a user
```bash
curl -X PUT http://localhost:3000/users/1 \
-H "Content-Type: application/json" \
-d '{"name": "John Smith", "email": "johnsmith@example.com"}'
```

#### Delete a user
```bash
curl -X DELETE http://localhost:3000/users/1
```

## Development

For local development:

1. Install dependencies:
```bash
npm install
```

2. Start PostgreSQL container separately:
```bash
docker run --name postgres-container \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=adminpassword \
  -e POSTGRES_DB=node_crud \
  -v ./docker-entrypoint-initdb.d:/docker-entrypoint-initdb.d \
  -p 5432:5432 \
  -d postgres:15
```

3. Run the application:
```bash
npm start
```



