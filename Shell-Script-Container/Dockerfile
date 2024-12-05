# Use the official Alpine linux image as the base image
FROM alpine:latest

# Copy the custom Shell Script from the host to the container's web root
COPY test_script.sh /root/

# Permission change on Shell Script
RUN chmod +x /root/test_script.sh

# Run Shell script 
ENTRYPOINT ["sh", "/root/test_script.sh"]
CMD ["Docker Container"]
