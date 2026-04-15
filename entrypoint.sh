#!/bin/bash

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

if [ ! -f "$CONFIG_DIR/plugins/xmwebui/xmwebui.jar" ]; then
    echo "First run: Forcing WebUI Installation..."
    
    # We use a subshell and a timeout to ensure it doesn't hang the whole boot
    (
        sleep 15 # Give the engine time to initialize
        echo "plugin install xmwebui"
        sleep 5
        echo "set \"Plugin.xmwebui.Password Enable\" true boolean"
        echo "set \"Plugin.xmwebui.User\" \"admin\" string"
        echo "set \"Plugin.xmwebui.Password\" \"admin\" password"
        echo "set \"Plugin.xmwebui.Port\" 9091 int"
        echo "cfg save"
        sleep 2
        echo "quit"
    ) | java $JAVA_ARGS -cp "$CP" com.biglybt.ui.Main --ui=console
fi

echo "Starting BiglyBT Engine..."

exec java $JAVA_ARGS -cp "$CP" com.biglybt.ui.Main --ui=console < /dev/null
