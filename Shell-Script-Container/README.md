# Alpine Linux Custom Docker Container

## 🚀 Project Overview

This project demonstrates how to create a custom Docker container using Alpine Linux, showcasing containerization best practices, scripting, and container management techniques.

## 📋 Table of Contents
- [Prerequisites](#prerequisites)
- [Project Structure](#project-structure)
- [Dockerfile Breakdown](#dockerfile-breakdown)
- [Shell Script Explanation](#shell-script-explanation)
- [Build and Run Instructions](#build-and-run-instructions)
- [Advanced Usage](#advanced-usage)
- [Troubleshooting](#troubleshooting)
- [Best Practices](#best-practices)

## 📂 Project Structure
```
project-root/
│
├── Dockerfile          # Docker image build instructions
├── test_script.sh      # Entrypoint shell script
└── README.md           # Project documentation
```

## 🐳 Dockerfile Breakdown

### Base Image Selection
- **Image**: `alpine:latest`
- **Why Alpine?**
  - Extremely lightweight (~ 5MB)
  - Security-focused distribution
  - Minimal attack surface
  - Fast build and startup times

### Dockerfile Stages
1. **Base Image Setup**: Uses Alpine Linux as foundation
2. **File Copying**: Transfers `test_script.sh` to container
3. **Permission Configuration**: Ensures script is executable
4. **Entrypoint Definition**: Sets script as container startup command

## 🚢 Shell Script Explanation

### `test_script.sh` Functionality
- **Purpose**: Demonstrate container initialization and persistence
- **Key Features**:
  - Dynamic greeting with argument support
  - Simulates long-running process
  - Provides extensibility for complex startup routines

### Script Behavior
- Prints personalized "Hello, World" message
- Sleeps for 100 seconds to maintain container activity
- Accepts optional custom argument

## 🔧 Build and Run Instructions

### Image Build
```bash
# Standard build
docker build -t custom-container .

# Build with additional context
docker build --no-cache -t custom-container .
```

### Container Execution
```bash
# Basic run
docker run -it --name custom-container-shell custom-container

# Run with custom argument
docker run -it --name custom-container-shell custom-container "Custom Greeting"

# Detached mode
docker run -d --name custom-container-background custom-container
```

## 🚀 Advanced Usage

### Container Management
```bash
# List running containers
docker ps

# Stop container
docker stop custom-container-shell

# Remove container
docker rm custom-container-shell

# Remove image
docker rmi custom-container
```

## 🛠️ Troubleshooting

### Common Issues
- **Permission Denied**: Ensure `chmod +x` is used
- **Build Failures**: Check Dockerfile syntax
- **Script Not Executing**: Verify line endings (CRLF vs LF)

### Debugging Tips
- Use `docker logs` to inspect container output
- Add verbose logging in `test_script.sh`
- Validate script locally before containerization

## 📝 Best Practices

### Docker Recommendations
- Use specific version tags instead of `latest`
- Minimize layer count
- Avoid running containers as root
- Implement multi-stage builds for production

### Shell Scripting Guidelines
- Add error handling
- Use `set -e` for strict error checking
- Implement logging mechanisms
- Validate input parameters

