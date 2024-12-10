# Use the official Nginx image as the base image
FROM nginx:latest

# Copy custom configuration file to Nginx directory
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy the custom HTML content to the Nginx default root directory
COPY index.html /usr/share/nginx/html/index.html

# Expose port 80
EXPOSE 80
