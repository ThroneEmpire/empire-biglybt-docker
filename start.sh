#!/bin/bash
cd "$(dirname "$0")"

if [ ! -f .env ]; then
    echo "Error: .env file not found."
    echo "Copy .env.example to .env and fill in your VPN credentials:"
    echo "  cp .env.example .env"
    exit 1
fi

REQUIRED="VPN_SERVICE_PROVIDER WIREGUARD_PRIVATE_KEY WIREGUARD_ADDRESSES SERVER_HOSTNAMES"
MISSING=""
for VAR in $REQUIRED; do
    VALUE=$(grep "^$VAR=" .env | cut -d= -f2-)
    if [ -z "$VALUE" ] || [[ "$VALUE" == your_* ]]; then
        MISSING="$MISSING $VAR"
    fi
done

if [ -n "$MISSING" ]; then
    echo "Error: missing or placeholder values in .env for:$MISSING"
    echo "Edit .env and fill in your VPN credentials."
    exit 1
fi

docker compose pull
docker compose up -d --build
