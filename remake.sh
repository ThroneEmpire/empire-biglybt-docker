#!/bin/bash
cd "$(dirname "$0")"

echo "Stopping and removing Docker resources..."
docker compose down --rmi all --volumes --remove-orphans

echo "Wiping local config and download files..."
sudo rm -rf ./config ./downloads ./biglybt

WG_KEY=$(grep WIREGUARD_PRIVATE_KEY .env 2>/dev/null | cut -d= -f2-)
if [ -n "$WG_KEY" ]; then
    read -rp "Preserve VPN credentials? [Y/n]: " KEEP_VPN
    if [[ "$KEEP_VPN" =~ ^[Nn] ]]; then
        VPN_PROVIDER=""
        WG_KEY=""
        WG_ADDR=""
        WG_HOST=""
    else
        VPN_PROVIDER=$(grep VPN_SERVICE_PROVIDER .env 2>/dev/null | cut -d= -f2-)
        WG_ADDR=$(grep WIREGUARD_ADDRESSES .env 2>/dev/null | cut -d= -f2-)
        WG_HOST=$(grep SERVER_HOSTNAMES .env 2>/dev/null | cut -d= -f2-)
    fi
fi

rm -f ./.env

[ -n "$VPN_PROVIDER" ] && echo "VPN_SERVICE_PROVIDER=$VPN_PROVIDER" >> .env
[ -n "$WG_KEY" ] && echo "WIREGUARD_PRIVATE_KEY=$WG_KEY" >> .env
[ -n "$WG_ADDR" ] && echo "WIREGUARD_ADDRESSES=$WG_ADDR" >> .env
[ -n "$WG_HOST" ] && echo "SERVER_HOSTNAMES=$WG_HOST" >> .env

echo "Rebuilding and starting..."
docker compose up -d --build --force-recreate

echo "-----------------------------------------------------"
echo "Done! Give BiglyBT about 60 seconds to install on first boot."
echo "Check progress with: docker logs -f biglybt"
