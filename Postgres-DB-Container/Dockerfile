# Use the PostgreSQL 15 base image
FROM postgres:15

# Install packages
RUN apt-get update && apt-get install -y \
    procps \
    openssh-server \
    openssh-client \    
    vim \
    iputils-ping \      
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV POSTGRES_USER=admin
ENV POSTGRES_PASSWORD=admin123
ENV POSTGRES_DB=mydb

# Copy custom initialization scripts (optional)
COPY init.sql /docker-entrypoint-initdb.d/
