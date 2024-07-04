# Docker Redis for Dokku on K3S

This repository provides a Dockerized Redis setup specifically designed for use with Dokku on a K3S cluster. The official Dokku Redis plugin is not an option because it deploys Redis in the standard Docker, while we aim to have Redis within the K3S cluster. This setup allows for generating and setting a Redis password, making it secure and easy to use.

## Features

- Generates a random Redis password if not provided.
- Stores the password as an environment variable.
- Easy deployment with Dokku on K3S.
- Designed to work seamlessly with the [Redis Object Cache](https://wordpress.org/plugins/redis-cache/) WordPress plugin.

## Prerequisites

- Dokku installed on your server.
- K3S cluster set up and configured.
- `kubectl` installed and configured to manage your K3S cluster.

## Installation

### Step 1: Clone the Repository

Clone the repository to your local machine:

```bash
git clone https://github.com/dmitryrechkin/docker-redis.git
cd docker-redis
```

### Step 2: Modify the Entrypoint Script

The `entrypoint.sh` script generates a Redis password if one is not provided. It sets this password in the Redis configuration file.

### Step 3: Modify the Dockerfile

The `Dockerfile` ensures the Redis configuration directory exists and uses the `entrypoint.sh` script to start Redis with the correct configuration.

### Step 4: Deploy to Dokku

1. Create a new Dokku Redis app:

    ```bash
    dokku apps:create redis-app
    ```

2. Push your Dokku Redis app:

    ```bash
    git push dokku main
    ```

### Step 5: Set Environment Variables

Set the `REDIS_PASSWORD` environment variable for your Dokku app. If you want to manually set a password, you can do so:

```bash
dokku config:set redis-app REDIS_PASSWORD=<your-strong-password>
```

If you do not set a password, a random one will be generated and displayed in the logs.

### Step 6: Remove Public Domain

To ensure that your Redis instance is not exposed publicly, remove the domain:

```bash
dokku domains:remove redis-app
```

### Step 7: Expose Redis Port

Ensure that the Redis app exposes the necessary port:

```bash
dokku proxy:ports-add redis-app http:6379:6379
```

### Step 8: Mount Storage (Optional)

To persist Redis data, you can mount a storage volume:

1. Create a directory on your Dokku host for Redis data:

    ```bash
    sudo mkdir -p /var/lib/dokku/data/storage/redis-app
    ```

2. Mount the storage directory to your Dokku app:

    ```bash
    dokku storage:mount redis-app /var/lib/dokku/data/storage/redis-app:/data
    ```

3. Restart the Redis app to apply the storage settings:

    ```bash
    dokku ps:restart redis-app
    ```

### Step 9: Verify Deployment

Ensure the Redis app is running:

```bash
dokku ps:report redis-app
```

### Step 10: Connect to Redis

You can connect to the Redis instance using the password. If the password was auto-generated, you can view it in the logs or by accessing the environment variable:

```bash
dokku logs redis-app
```

or

```bash
dokku config:get redis-app REDIS_PASSWORD
```

## Connecting to Redis from Another Dokku App (K3S Pod)

To connect to the Redis instance from another Dokku app (K3S Pod) in the same cluster, such as a WordPress container using the Redis Object Cache plugin, set the following environment variables. Run the following command in the app's folder:

```bash
dokku config:set WP_REDIS_HOST=redis-app-web WP_REDIS_PORT=6379 WP_REDIS_PREFIX=unique-site-prefix WP_REDIS_DATABASE=0 WP_REDIS_PASSWORD=<your-redis-password> WP_REDIS_SCHEME=redis
```

- `redis-app-web`: The name of the K3S service for the Redis app (you can find it using `kubectl get services`). Typically it is the name of the app with "-web" suffix.
- `<your-redis-password>`: The Redis password (either set manually or generated).

## Troubleshooting

- Ensure the Redis app is running by checking its status with `dokku ps:report redis-app`.
- Check the logs for any errors using `dokku logs redis-app`.
- Verify the Redis password is set correctly by viewing it with `dokku config:get REDIS_PASSWORD` from within the app's folder.
