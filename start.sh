#!/bin/bash

echo "Starting OpenClaw..."

# root dir
cd ~

openclaw gateway run &
echo $! > ~/.openclaw/gateway.pid

sleep 3

# list scheduled tasks
# reminder not in schedule -> regist tasks, save to log
if ! crontab -l 2>/dev/null | grep -q "reminder.py"; then
  (crontab -l 2>/dev/null; echo "*/5 * * * * python3 $REMINDER >> /tmp/reminder.log 2>&1") | crontab -
  echo "Study reminder registered."
else
  echo "Study reminder already registered."
fi

echo ""
echo "OpenClaw is running!"
echo "Your Telegram bot is now active."
echo ""
echo "To stop it, run:  bash stop.sh"