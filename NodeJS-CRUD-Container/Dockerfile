# Use the official Node.js image as the base
FROM node:18

# Set the working directory inside the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json to the container
COPY package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of the application code to the container
COPY . .

# Run tests
RUN npm test

# Expose the application's port (change if different)
EXPOSE 3000

# Command to run the application
CMD ["npm", "start"]


