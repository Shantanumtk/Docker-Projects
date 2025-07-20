# Use the official Alpine linux image as the base image
FROM alpine:latest

# Copy the custom Shell Scripts from the host to the container
COPY test_script.sh /root/
COPY cron_replayer.sh /root/
COPY cron_config.json /root/

# Permission change on Shell Scripts
RUN chmod +x /root/test_script.sh /root/cron_replayer.sh

# Run Shell script (default remains test_script.sh for backward compatibility)
ENTRYPOINT ["sh", "/root/test_script.sh"]
CMD ["Docker Container"]
