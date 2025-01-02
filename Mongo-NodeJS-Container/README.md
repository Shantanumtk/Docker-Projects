# NodeJS MongoDB CRUD API with Docker

A containerized REST API built with Node.js and MongoDB, implementing complete CRUD operations for user management. The application runs in two separate Docker containers - one for the Node.js application and another for MongoDB.

## Features
- RESTful API endpoints for user management
- MongoDB database for data persistence
- Docker containerization (separate containers)
- Express.js server
- Mongoose ODM
- Environment-based configuration
- Automated setup and test script
- Health check endpoint
- CORS enabled

## Project Structure
```
project-root/
├── src/
│   ├── models/
│   │   └── user.model.js        # User schema definition
│   ├── routes/
│   │   └── user.routes.js       # API endpoints
│   ├── config/
│   │   └── database.js          # MongoDB connection
│   └── server.js                # Application entry point
├── .env                         # Environment variables
├── .gitignore                   # Git ignore rules
├── Dockerfile                   # Node.js container config
├── run.sh                       # Automated setup script
├── package.json                 # Project dependencies
└── README.md                    # Project documentation
```

## Prerequisites
- Docker
- Node.js (for local development)
- curl or Postman (for testing)
- Bash shell (for running the setup script)

## Quick Start

### Option 1: Using Automated Script (Recommended)

1. Clone the repository and navigate to the project directory:
```bash
git clone <repository-url>
cd <project-directory>
```

2. Create `.env` file:
```plaintext
MONGODB_URI=mongodb://mongo-container:27017/userdb
PORT=3000
```

3. Run the automated setup script:
```bash
chmod +x run.sh
./run.sh
```

The script will:
- Create and run the MongoDB container
- Build and run the Node.js application
- Create a test user
- Verify the setup by retrieving all users

### Option 2: Manual Setup

1. Create Docker network:
```bash
docker network create mongo-node-network
```

2. Run MongoDB container:
```bash
docker run -d \
  --name mongo-container \
  --network mongo-node-network \
  -p 27017:27017 \
  mongo:latest
```

3. Build and run Node.js application:
```bash
# Build the image
docker build -t node-mongo-app .

# Run the container
docker run -d \
  --name node-container \
  --network mongo-node-network \
  -p 3000:3000 \
  node-mongo-app
```

## Automation Script (run.sh)
```bash
#!/bin/bash
# Running MongoDB Container
docker run -d \
  --name mongo-container \
  --network mongo-node-network \
  -p 27017:27017 \
  mongo:latest
sleep 15
# Build and Running NodeJS Container
# Build the image
docker build -t node-mongo-app .
sleep 10
# Run the container
docker run -d \
  --name node-container \
  --network mongo-node-network \
  -p 3000:3000 \
  node-mongo-app
sleep 15
# API Testing
#Creating a User
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"John Doe","email":"john@example.com"}'
#Get All Users
curl http://localhost:3000/api/users
```

## API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET    | /api/users | Get all users |
| GET    | /api/users/:id | Get user by ID |
| POST   | /api/users | Create new user |
| PUT    | /api/users/:id | Update user |
| DELETE | /api/users/:id | Delete user |
| GET    | /health | Health check |

## API Usage Examples

### Create User
```bash
curl -X POST http://localhost:3000/api/users \
  -H "Content-Type: application/json" \
  -d '{"name":"John Doe","email":"john@example.com"}'
```

### Get All Users
```bash
curl http://localhost:3000/api/users
```

### Get User by ID
```bash
curl http://localhost:3000/api/users/{user_id}
```

### Update User
```bash
curl -X PUT http://localhost:3000/api/users/{user_id} \
  -H "Content-Type: application/json" \
  -d '{"name":"John Updated","email":"john.updated@example.com"}'
```

### Delete User
```bash
curl -X DELETE http://localhost:3000/api/users/{user_id}
```

## Development

For local development:

1. Install dependencies:
```bash
npm install
```

2. Start MongoDB container:
```bash
docker run -d \
  --name mongo-container \
  -p 27017:27017 \
  mongo:latest
```

3. Update `.env` file for local development:
```plaintext
MONGODB_URI=mongodb://localhost:27017/userdb
PORT=3000
```

4. Run the application:
```bash
npm run dev
```

## Container Management

### View Logs
```bash
# MongoDB logs
docker logs mongo-container

# Node.js app logs
docker logs node-container
```

### Container Commands
```bash
# Stop containers
docker stop node-container mongo-container

# Remove containers
docker rm node-container mongo-container

# Remove network
docker network rm mongo-node-network
```

## Troubleshooting

1. Script Execution Issues:
   - Ensure run.sh has execute permissions (`chmod +x run.sh`)
   - Check if ports 3000 and 27017 are available
   - Verify no containers with same names exist

2. Container Communication Issues:
   - Verify both containers are on the same network
   - Check network settings using `docker network inspect mongo-node-network`
   - Ensure container names match the connection string

3. MongoDB Connection Issues:
   - Check if MongoDB container is running
   - Verify MONGODB_URI in .env file
   - Check MongoDB logs using `docker logs mongo-container`
