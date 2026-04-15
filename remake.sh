#!/bin/bash

# 1. Stop and remove the container, networks, and images associated with this project
echo "Stopping and removing Docker resources..."
docker compose down --rmi all --volumes --remove-orphans

# 2. Delete the local configuration and downloads directories
# This wipes the /config folder so the next run triggers "First run detected"
echo "Wiping local config and download files..."
sudo rm -rf ./config ./downloads

# 3. Rebuild the image from scratch (ignoring the cache to ensure a fresh Java environment)
echo "Rebuilding and starting..."
docker compose up -d --build --force-recreate

echo "-----------------------------------------------------"
echo "Done! Give BiglyBT about 60 seconds to install the plugin."
echo "Check progress with: docker logs -f biglybt"
