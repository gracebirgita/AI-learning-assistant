#!/bin/bash

echo "Starting OpenClaw..."
openclaw gateway run &

# Save the process ID so stop.sh knows what to kill
echo $! > ~/.openclaw/gateway.pid

sleep 3

echo ""
echo "OpenClaw is running!"
echo "Your Telegram bot is now active."
echo ""
echo "To stop it, run:  bash stop.sh"