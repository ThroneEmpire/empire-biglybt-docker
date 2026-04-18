#!/bin/bash
echo "Waiting for BiglyBT tmux session to be ready..."
until docker exec biglybt tmux -S /tmp/bbt.sock has-session -t bbt 2>/dev/null; do
    sleep 1
done
echo "BiglyBT is ready. To detach without stopping it, press Ctrl+B then D."
read -p "Press Enter to continue..."
docker exec -it biglybt tmux -S /tmp/bbt.sock attach -t bbt
