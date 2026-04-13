#!/bin/bash

echo "Starting OpenClaw..."

# root dir
cd ~

openclaw gateway run &
echo $! > ~/.openclaw/gateway.pid

sleep 3

echo "Registering study reminder..."

# get PATH
OPENCLAW_PATH=$(which openclaw)
REMINDER="/workspaces/AI-learning-assistant/workspace/skills/reminder/scripts/reminder.py"
CURRENT_PATH=$PATH

# Check crontab is available
if ! command -v crontab &> /dev/null; then
  echo "crontab not found, installing..."
  sudo apt-get install -y cron -qq
  sudo service cron start
fi

# list scheduled tasks
# reminder not in schedule -> regist tasks, save to log
if ! crontab -l 2>/dev/null | grep -q "reminder.py"; then
  (crontab -l 2>/dev/null; echo "*/5 * * * * PATH=$CURRENT_PATH python3 $REMINDER >> /tmp/reminder.log 2>&1") | crontab -
  echo "Study reminder registered."
else
  echo "Study reminder already registered."
fi

# Verify it actually got registered
echo "Verifying crontab..."
crontab -l 2>/dev/null | grep "reminder.py" && echo "Confirmed." || echo "WARNING: Registration failed."

echo ""
echo "OpenClaw is running!"
echo "Your Telegram bot is now active."
echo ""
echo "To stop it, run:  bash stop.sh"
