#!/bin/bash
export TMUX_TMPDIR=/tmp

CONFIG_DIR="/config"
BIGLY_DIR="/opt/biglybt"
CP="$BIGLY_DIR/BiglyBT.jar:$BIGLY_DIR/commons-cli.jar"

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

SETUP_SOCK="/tmp/bbt-setup.sock"
SETUP_SESSION="bbt-setup"
SETUP_LOG="/tmp/bbt-setup.log"

start_setup_console() {
    rm -f "$SETUP_LOG"
    tmux -S "$SETUP_SOCK" new-session -d -s "$SETUP_SESSION" \
        "java $JAVA_ARGS -cp \"$CP\" com.biglybt.ui.Main --ui=console 2>&1 | tee $SETUP_LOG"
}

wait_for_prompt() {
    for i in $(seq 1 30); do
        grep -q "^> -----" "$SETUP_LOG" 2>/dev/null && return 0
        sleep 1
    done
    echo "Timed out waiting for BiglyBT console prompt"
    return 1
}

send_cmd() {
    tmux -S "$SETUP_SOCK" send-keys -t "$SETUP_SESSION" "$1" Enter
}

quit_setup_console() {
    send_cmd "quit"
    for i in $(seq 1 15); do
        tmux -S "$SETUP_SOCK" has-session -t "$SETUP_SESSION" 2>/dev/null || break
        sleep 1
    done
    tmux -S "$SETUP_SOCK" kill-session -t "$SETUP_SESSION" 2>/dev/null || true
}

# First run: set download directories
if [ ! -f "$CONFIG_DIR/.empire-biglybt-initial-config" ]; then
    echo "Configuring download directories..."
    start_setup_console
    wait_for_prompt

    send_cmd "set \"Default save path\" \"/downloads\" string"
    sleep 1
    send_cmd "set \"Completed Files Directory\" \"/downloads\" string"
    sleep 1
    send_cmd "cfg save"
    sleep 2

    quit_setup_console
    touch "$CONFIG_DIR/.empire-biglybt-initial-config"
    echo "Download directories configured."
fi

# Disable unwanted built-in plugins (runs once)
UNWANTED_PLUGINS="azmsgsync azbuddy azintsimpleapi azlocaltracker azbpupnp azbpsharehoster azbpcoreupdater azbppluginupdate azupdater azplatform2 azintnettest"

if [ ! -f "$CONFIG_DIR/.empire-biglybt-plugins-disabled" ]; then
    echo "Disabling unwanted plugins..."
    start_setup_console
    wait_for_prompt

    for PLUGIN in $UNWANTED_PLUGINS; do
        send_cmd "set \"PluginInfo.$PLUGIN.enabled\" false boolean"
        sleep 1
    done
    send_cmd "cfg save"
    sleep 2

    quit_setup_console
    touch "$CONFIG_DIR/.empire-biglybt-plugins-disabled"
    echo "Plugins disabled."
fi

echo "Starting BiglyBT Engine inside Tmux..."

touch /tmp/biglybt.log
tmux -S /tmp/bbt.sock new-session -d -s bbt -n biglybt \
    "java $JAVA_ARGS -cp \"$CP\" com.biglybt.ui.Main --ui=console 2>&1 | tee /tmp/biglybt.log"

tmux -S /tmp/bbt.sock new-window -t bbt -n watcher "bash /opt/biglybt/port-watcher.sh"

tail -f /tmp/biglybt.log
