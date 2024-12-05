# Custom Apache Docker Project

This project demonstrates how to run an Apache web server in a Docker container using the httpd:alpine image, with a custom index.html file.

## Prerequisites

- Docker installed on your system
- A custom index.html file located at: `/home/centos/docker_project_files/my-index.html`

## Running the Apache Web Server

### Option 1: Run with Volume Mount

To run the container and replace the default index.html with the one from the host machine:

```bash
docker run -d --name apache-web-server -p 3000:80 -v /home/centos/docker_project_files/my-index.html:/usr/local/apache2/htdocs/index.html httpd:alpine
```

### Option 2: Build a Custom Docker Image

#### Create a Dockerfile

First, create a Dockerfile in your project directory:

```dockerfile
FROM httpd:alpine
COPY my-index.html /usr/local/apache2/htdocs/index.html
```

#### Build and Run the Custom Image

Build the Docker image:

```bash
docker build -t custom-apache .
```

Run the container using the custom image:

```bash
docker run -d --name apache-web-server -p 3000:80 custom-apache
```

## Accessing the Web Server

Once the container is running, you can access the web server by visiting:

- `http://localhost:3000`
- `http://<host-ip>:3000`

## Notes

- Ensure your custom `my-index.html` file is in the correct location before running the commands
- Port 3000 is mapped to the container's port 80
- The `httpd:alpine` image is used for a lightweight Apache web server
