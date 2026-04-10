#!/bin/bash

echo "Starting OpenClaw..."

# root dir
cd ~

openclaw gateway run &
echo $! > ~/.openclaw/gateway.pid

sleep 3

echo ""
echo "OpenClaw is running!"
echo "Your Telegram bot is now active."
echo ""
echo "To stop it, run:  bash stop.sh"
