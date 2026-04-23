#!/bin/bash
cd "$(dirname "$0")"

PLUGIN_URL="https://github.com/ThroneEmpire/empire-biglybt-nexus-plugin/releases/download/latest/Nexus_1.jar"
PLUGIN_DIR="./config/plugins/nexus"
PLUGIN_JAR="$PLUGIN_DIR/Nexus_1.jar"

echo "=== Nexus Web UI Plugin Installer ==="
echo ""

if ! docker inspect -f '{{.State.Running}}' biglybt 2>/dev/null | grep -q true; then
    echo "Error: BiglyBT container is not running. Start it first with ./start.sh"
    exit 1
fi

if [ -f "$PLUGIN_JAR" ]; then
    read -rp "Nexus plugin already installed. Reinstall/update? [y/N]: " CONFIRM
    [[ "$CONFIRM" =~ ^[Yy]$ ]] || exit 0
fi

# --- Ask configuration questions ---

read -rp "Port to run Nexus on [8090]: " NEXUS_PORT
NEXUS_PORT="${NEXUS_PORT:-8090}"

read -rp "Username [admin]: " NEXUS_USER
NEXUS_USER="${NEXUS_USER:-admin}"

while true; do
    read -rsp "Password: " NEXUS_PASS
    echo ""
    if [ -n "$NEXUS_PASS" ]; then break; fi
    echo "Password is required."
done

read -rp "Bypass authentication? [y/N]: " BYPASS_AUTH
if [[ "$BYPASS_AUTH" =~ ^[Yy]$ ]]; then
    NEXUS_BYPASS="true"
else
    NEXUS_BYPASS="false"
fi

read -rp "Web UI folder path inside container (e.g. /config/webui, leave blank to skip): " WEBUI_PATH

echo ""

# --- Download plugin ---

echo "Downloading Nexus plugin..."
mkdir -p "$PLUGIN_DIR"
if ! curl -fL "$PLUGIN_URL" -o "$PLUGIN_JAR"; then
    echo "Error: failed to download plugin."
    exit 1
fi
echo "Plugin downloaded."

# --- Apply configuration ---

apply_config() {
    docker exec biglybt \
        tmux -S /tmp/bbt.sock send-keys -t bbt:biglybt \
        "$1" Enter
    sleep 1
}

echo "Applying configuration..."

apply_config "set \"nexus.http.port\" $NEXUS_PORT int"
apply_config "set \"nexus.auth.username\" $NEXUS_USER string"
apply_config "set \"nexus.auth.bypass\" $NEXUS_BYPASS boolean"

apply_config "set \"nexus.auth.password\" $NEXUS_PASS string"
apply_config "set \"nexus.auth.password.usermodified\" true boolean"

if [ -n "$WEBUI_PATH" ]; then
    apply_config "set \"nexus.webui.path\" $WEBUI_PATH string"
fi

apply_config "cfg save"

echo "Restarting BiglyBT to load the plugin..."
docker restart biglybt

echo ""
echo "Done! Almost there — one manual step remaining:"
echo "  Uncomment port $NEXUS_PORT in docker-compose.yml under the gluetun ports section,"
echo "  then run: docker compose up -d"
echo ""
