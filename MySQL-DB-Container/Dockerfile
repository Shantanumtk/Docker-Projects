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
