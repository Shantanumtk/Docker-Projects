# Use the official Apache HTTP Server (Alpine-based) image as the base image
FROM httpd:alpine

# Copy the custom index.html from the host to the container's web root
COPY index.html /usr/local/apache2/htdocs/

# Expose port 80 (default port for Apache)
EXPOSE 80
