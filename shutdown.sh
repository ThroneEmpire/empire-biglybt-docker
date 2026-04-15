#!/bin/bash
cd "$(dirname "$0")"

echo "Stopping Gluetun + qBittorrent..."
docker compose down

echo "All containers stopped."
