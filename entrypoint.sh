#!/bin/bash
export TMUX_TMPDIR=/tmp
mkdir -p /tmp

# Configuration Paths
CONFIG_DIR="/config"
BIGLY_DIR="/opt/biglybt"
CP="$BIGLY_DIR/BiglyBT.jar:$BIGLY_DIR/commons-cli.jar"

# Java 11+ Headless Compatibility
JAVA_ARGS="--add-opens=java.base/java.net=ALL-UNNAMED \
--add-opens=java.base/java.lang=ALL-UNNAMED \
--add-opens=java.base/java.util=ALL-UNNAMED \
--add-opens=java.base/java.io=ALL-UNNAMED \
--add-opens=java.base/java.lang.reflect=ALL-UNNAMED \
-Djava.awt.headless=true \
-Dcom.biglybt.ui.headless=true \
-Dazureus.config.path=$CONFIG_DIR \
-Dazureus.install.path=$BIGLY_DIR"

mkdir -p "$CONFIG_DIR"

export _JAVA_OPTIONS="-Dcom.biglybt.console.batch=1 -Dcom.biglybt.console.skip_updates=1"

# Run only on first webui setup
if [ ! -d "$CONFIG_DIR/plugins/xmwebui" ]; then
    echo "First run: WebUI directory not found. Installing..."
    (
        sleep 15 
        echo "plugin install xmwebui"
        sleep 5
        echo "set \"Plugin.xmwebui.Password Enable\" true boolean"
        echo "set \"Plugin.xmwebui.User\" \"admin\" string"
        echo "set \"Plugin.xmwebui.Password\" \"admin\" password"
        echo "set \"Plugin.xmwebui.Port\" 9091 int"
        # Set download directory
        echo "set \"Default save path\" \"/downloads\" string"
        echo "set \"Completed Files Directory\" \"/downloads\" string"

        echo "cfg save"
        sleep 2
        echo "quit"
    ) | java $JAVA_ARGS -cp "$CP" com.biglybt.ui.Main --ui=console
else
    echo "WebUI already exists in $CONFIG_DIR/plugins/xmwebui. Skipping setup."
fi

# Disable unwanted built-in plugins (runs once)
UNWANTED_PLUGINS="azmsgsync azbuddy azintsimpleapi azlocaltracker azbpupnp azbpsharehoster"

if [ ! -f "$CONFIG_DIR/.plugins-disabled" ]; then
    echo "Disabling unwanted plugins..."
    (
        sleep 15
        for PLUGIN in $UNWANTED_PLUGINS; do
            echo "set \"PluginInfo.$PLUGIN.enabled\" false boolean"
        done
        echo "cfg save"
        sleep 2
        echo "quit"
    ) | java $JAVA_ARGS -cp "$CP" com.biglybt.ui.Main --ui=console
    touch "$CONFIG_DIR/.plugins-disabled"
    echo "Unwanted plugins disabled."
fi

# Start the watcher in background
bash /opt/biglybt/port-watcher.sh &

echo "Starting BiglyBT Engine inside Tmux..."

touch /tmp/biglybt.log
tmux -S /tmp/bbt.sock new-session -d -s bbt "java $JAVA_ARGS -cp \"$CP\" com.biglybt.ui.Main --ui=console 2>&1 | tee /tmp/biglybt.log"

tail -f /tmp/biglybt.log
