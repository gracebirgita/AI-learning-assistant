#!/bin/bash

if [ -f ~/.openclaw/gateway.pid ]; then
  PID=$(cat ~/.openclaw/gateway.pid)
  kill $PID 2>/dev/null && echo "OpenClaw stopped." || echo "Gateway was not running."
  rm ~/.openclaw/gateway.pid
else
  echo "OpenClaw is not running."
fi