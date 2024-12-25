# Docker Network Project - Master-Slave Architecture Setup Guide

## Overview
This guide details the setup of a Docker-based master-slave architecture using CentOS 7 containers. The setup consists of one master node and two slave nodes, all connected through a custom bridge network.

## Prerequisites
- Docker installed and running
- Basic understanding of Docker networking
- Basic understanding of SSH and key-based authentication

## Network Architecture
- Network Type: Custom Bridge Network
- Subnet: 172.168.0.0/24
- Master Node IP: 172.168.0.2
- Slave1 Node IP: 172.168.0.3
- Slave2 Node IP: 172.168.0.4
- Port Mappings:
  - Master: 2222:22
  - Slave1: 2223:22
  - Slave2: 2224:22

## Dockerfile Configurations

### Master Server Configuration
```dockerfile
FROM centos:7

# Switch to vault mirrors for CentOS 7 (required since EOL)
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

# Install required packages
RUN yum install -y epel-release && \
    yum update -y && \
    yum install -y \
    python3 \
    ansible \
    openssh-server \
    openssh-clients \
    vim \
    iputils \
    sshpass && \
    yum clean all

# Configure SSH server
RUN mkdir /var/run/sshd && \
    echo 'root:root' | chpasswd && \
    sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    ssh-keygen -A

# Expose SSH port
EXPOSE 22

# Start SSH daemon
CMD ["/usr/sbin/sshd", "-D"]
```

### Slave Server Configuration
```dockerfile
FROM centos:7

# Switch to vault mirrors for CentOS 7 (required since EOL)
RUN sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* && \
    sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

# Install required packages
RUN yum install -y \
    python3 \
    openssh-server \
    vim \
    iputils && \
    yum clean all

# Configure SSH server
RUN mkdir /var/run/sshd && \
    echo 'root:root' | chpasswd && \
    sed -i 's/#PermitRootLogin yes/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    ssh-keygen -A

# Expose SSH port
EXPOSE 22

# Start SSH daemon
CMD ["/usr/sbin/sshd", "-D"]
```

## Setup Instructions

### 1. Create Network
Create a custom bridge network for container communication:
```bash
docker network create --subnet=172.168.0.0/24 bridge_network
```

### 2. Build Docker Images
Save the Dockerfiles with appropriate names and build the images:
```bash
# Build master image
docker build -f Dockerfile.master -t master-server .

# Build slave image
docker build -f Dockerfile.slave -t slave-server .
```

### 3. Run Containers
Launch the containers with specific IP addresses and port mappings:
```bash
# Launch master container
docker run -d \
  --name master \
  -p 2222:22 \
  --network bridge_network \
  --ip 172.168.0.2 \
  master-server

# Launch slave containers
docker run -d \
  --name slave1 \
  -p 2223:22 \
  --network bridge_network \
  --ip 172.168.0.3 \
  slave-server

docker run -d \
  --name slave2 \
  -p 2224:22 \
  --network bridge_network \
  --ip 172.168.0.4 \
  slave-server
```

### 4. Configure SSH Authentication
Set up SSH key-based authentication:
```bash
# Generate SSH key pair on master
docker exec -it master ssh-keygen -t rsa -b 2048 -f /root/.ssh/id_rsa -N ''

# Add slave hosts to known_hosts
docker exec -it master bash -c "ssh-keyscan 172.168.0.3 >> /root/.ssh/known_hosts"
docker exec -it master bash -c "ssh-keyscan 172.168.0.4 >> /root/.ssh/known_hosts"

# Copy SSH keys to slave nodes
docker exec -it master bash -c "sshpass -p 'root' ssh-copy-id root@172.168.0.3"
docker exec -it master bash -c "sshpass -p 'root' ssh-copy-id root@172.168.0.4"
```

### 5. Verify Connectivity
Test SSH connections from master to slave nodes:
```bash
# Test connection to Slave 1
docker exec -it master ssh root@172.168.0.3 'echo Slave 1 Connected'

# Test connection to Slave 2
docker exec -it master ssh root@172.168.0.4 'echo Slave 2 Connected'
```

## Additional Features and Security Considerations

### Security Enhancements
1. Change default passwords after initial setup
2. Implement SSH key rotation
3. Configure SSH to disable password authentication after key setup
4. Use secrets management for sensitive data

### Network Security
1. Implement network isolation using Docker network policies
2. Configure firewall rules to restrict access
3. Use encrypted communication channels

### Monitoring and Maintenance
1. Set up container health checks
2. Implement logging and monitoring
3. Create backup and restore procedures

## Troubleshooting

### Common Issues and Solutions
1. Container connectivity issues:
   ```bash
   docker network inspect bridge_network
   ```

2. SSH connection failures:
   ```bash
   docker exec -it master ssh -v root@172.168.0.3
   ```

3. Permission issues:
   ```bash
   docker exec -it master ls -la /root/.ssh
   docker exec -it slave1 ls -la /root/.ssh
   ```

### Logging and Debugging
1. View container logs:
   ```bash
   docker logs master
   docker logs slave1
   docker logs slave2
   ```

2. Check SSH server status:
   ```bash
   docker exec -it master systemctl status sshd
   ```

