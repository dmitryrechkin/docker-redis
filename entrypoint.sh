#!/bin/bash

# Generate a random password if REDIS_PASSWORD is not set
if [ -z "$REDIS_PASSWORD" ]; then
  REDIS_PASSWORD=$(openssl rand -base64 32)
  echo "Generated REDIS_PASSWORD: $REDIS_PASSWORD"
fi

# Create a Redis configuration file with the password
echo "requirepass $REDIS_PASSWORD" > /usr/local/etc/redis/redis.conf

# Export the password as an environment variable
export REDIS_PASSWORD=$REDIS_PASSWORD

# Run the main command
exec redis-server /usr/local/etc/redis/redis.conf
