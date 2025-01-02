#!/bin/bash

# Creating DB Container
docker run --name postgres-container \
  --network node-postgres-network \
  -e POSTGRES_USER=admin \
  -e POSTGRES_PASSWORD=adminpassword \
  -e POSTGRES_DB=node_crud \
  -v ./docker-entrypoint-initdb.d:/docker-entrypoint-initdb.d \
  -p 5434:5432 \
  -d postgres:15
  
sleep 15
  
# Running NodeJS Container 
docker run --name node-container \
  --network node-postgres-network \
  -p 3000:3000 \
  -d node-app-postgres
  
sleep 10

# API Testing
# POST Method
curl -X POST http://localhost:3000/users \
-H "Content-Type: application/json" \
-d '{"name": "Alice", "email": "alice@example.com"}'

# GET Method
curl http://localhost:3000/users
