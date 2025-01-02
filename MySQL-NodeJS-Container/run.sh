#!/bin/bash

# Run MySQL DB Container 
docker run --name mysql-container \
  --network my-network \
  -e MYSQL_ROOT_PASSWORD=rootpassword \
  -e MYSQL_DATABASE=crud_db \
  -e MYSQL_USER=user \
  -e MYSQL_PASSWORD=password \
  -v ./docker-entrypoint-initdb.d/init.sql:/docker-entrypoint-initdb.d/init.sql \
  -p 3306:3306 \
  -d mysql:8.0

sleep 10

# Build the image
docker build -t nodejs-api .

sleep 10

# Run the container
docker run --name nodejs-container \
  --network my-network \
  -p 3000:3000 \
  -d nodejs-api
  
sleep 20

# Create a user
curl -X POST http://localhost:3000/api/users \
-H "Content-Type: application/json" \
-d '{"name": "Ethan Hunt", "email": "ethan.hunt@example.com"}'

# Get all users
curl http://localhost:3000/api/users
