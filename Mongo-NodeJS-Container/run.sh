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

