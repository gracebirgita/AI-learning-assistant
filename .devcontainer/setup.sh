#!/bin/bash
set -e

echo "Installing system dependencies..."
sudo apt-get update -qq
sudo apt-get install -y cron

# Start cron
sudo service cron start

echo "Installing OpenClaw..."
npm install -g openclaw

echo "Creating OpenClaw config directory..."
mkdir -p ~/.openclaw/workspace

echo "Copying all workspace personality files..."

# checking: make sure workspace/ exists and has .md files
if [ ! -f "workspace/SOUL.md" ]; then
  echo "ERROR: workspace/SOUL.md not found."
  echo "Make sure your personality files are in the 'workspace/' folder in your repo root."
  echo "Current repo contents:"
  ls -la
  exit 1
fi

# copy into openclaw workspace
cp -r workspace/. ~/.openclaw/workspace/

# memory folder
echo "Setting memory folder..."
mkdir -p ~/.openclaw/workspace/memory

# copy state file (if doesn't exist)
if [ ! -f ~/.openclaw/workspace/memory/heartbeat-state.json ]; then
  cp workspace/memory/heartbeat-state.json \
     ~/.openclaw/workspace/memory/heartbeat-state.json
  echo "heartbeat-state.json initialized."
fi


# Verify copy worked
echo "Verifying personality files copied..."
ls ~/.openclaw/workspace/

echo "Validating required secrets..."
if [ -z "$TELEGRAM_BOT_TOKEN" ]; then
  echo "ERROR: TELEGRAM_BOT_TOKEN is not set. Add it to your Codespace secrets."
  exit 1
fi

if [ -z "$OPENROUTER_API_KEY" ] && [ -z "$GEMINI_API_KEY" ]; then
  echo "ERROR: No AI provider key found. Set at least one of:"
  echo "  OPENROUTER_API_KEY, or GEMINI_API_KEY"
  echo "  in your Codespace secrets before rebuilding."
  exit 1
fi

echo "Writing openclaw.json from template..."
cp /workspaces/AI-learning-assistant/config/openclaw.template.json ~/.openclaw/openclaw.json

# inject key
sed -i "s|__TELEGRAM_BOT_TOKEN__|${TELEGRAM_BOT_TOKEN}|g" ~/.openclaw/openclaw.json
sed -i "s|__OPENROUTER_API_KEY__|${OPENROUTER_API_KEY:-}|g" ~/.openclaw/openclaw.json
sed -i "s|__GEMINI_API_KEY__|${GEMINI_API_KEY:-}|g" ~/.openclaw/openclaw.json
# web searching
sed -i "s|__TAVILY_API_KEY__|${TAVILY_API_KEY:-}|g" ~/.openclaw/openclaw.json


echo "Making scripts executable..."
chmod +x start.sh stop.sh
chmod +x workspace/skills/reminder/scripts/reminder.py

# restart
bash stop.sh && bash start.sh
echo "OpenClaw setup complete!"
