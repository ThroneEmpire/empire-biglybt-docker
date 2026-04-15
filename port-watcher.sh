#!/bin/bash
PORT_FILE="/tmp/gluetun/forwarded_port"
LAST_PORT=""

# Wait a few seconds to make sure the tmux session is actually up
sleep 10 

while true; do
    if [ -f "$PORT_FILE" ]; then
        NEW_PORT=$(cat "$PORT_FILE")
        if [ "$NEW_PORT" != "$LAST_PORT" ] && [ ! -z "$NEW_PORT" ]; then
            echo "[Watcher] Updating BiglyBT to port $NEW_PORT"
            
            tmux -S /tmp/bbt.sock send-keys -t bbt "set TCP.Listen.Port $NEW_PORT" Enter
            tmux -S /tmp/bbt.sock send-keys -t bbt "set UDP.Listen.Port $NEW_PORT" Enter
            tmux -S /tmp/bbt.sock send-keys -t bbt "set UDP.NonData.Listen.Port $NEW_PORT" Enter
            tmux -S /tmp/bbt.sock send-keys -t bbt "cfg save" Enter
            
            LAST_PORT=$NEW_PORT
        fi
    fi
    sleep 30
done
