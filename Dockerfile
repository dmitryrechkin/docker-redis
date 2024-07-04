# Use the official Redis image from the Docker Hub
FROM redis:latest

# Install openssl for generating random passwords
RUN apt-get update && apt-get install -y openssl

# Create the directory for Redis configuration
RUN mkdir -p /usr/local/etc/redis

# Copy the entrypoint script
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Expose the default Redis port
EXPOSE 6379

# Command to run Redis server with the custom entrypoint
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
