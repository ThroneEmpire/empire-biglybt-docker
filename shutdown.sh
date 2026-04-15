#!/bin/bash

echo "Sending shutdown signal to BiglyBT..."

# 1. Tell the engine to save and stop gracefully
# We give it 15 seconds to flush the pieces to disk before forcing it
docker stop -t 15 biglybt

echo "BiglyBT has been shut down safely."
