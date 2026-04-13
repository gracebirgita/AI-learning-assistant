#!/bin/bash

if [ -f ~/.openclaw/gateway.pid ]; then
  PID=$(cat ~/.openclaw/gateway.pid)
  kill $PID 2>/dev/null && echo "OpenClaw stopped." || echo "Gateway was not running."
  rm ~/.openclaw/gateway.pid
else
  echo "OpenClaw is not running."
fi

# remove study reminder from crontab
crontab -l 2>/dev/null | grep -v "reminder.py" | crontab -
echo "Study reminder stopped."