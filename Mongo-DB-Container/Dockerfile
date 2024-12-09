# Use the official MongoDB image as the base image
FROM mongo:latest

# Set environment variables for MongoDB root user
ENV MONGO_INITDB_ROOT_USERNAME=root
ENV MONGO_INITDB_ROOT_PASSWORD=root_password

# Copy initialization scripts (optional)
COPY ./init.js /docker-entrypoint-initdb.d/

# Expose MongoDB port
EXPOSE 27017
