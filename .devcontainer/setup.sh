#!/bin/bash
set -e

echo "Installing OpenClaw..."
npm install -g openclaw

echo "Creating OpenClaw config directory..."
mkdir -p ~/.openclaw/workspace

echo "Copying all workspace personality files..."
cp -r workspace/. ~/.openclaw/workspace/

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
cp config/openclaw.template.json ~/.openclaw/openclaw.json

# inject key
sed -i "s|__TELEGRAM_BOT_TOKEN__|${TELEGRAM_BOT_TOKEN}|g" ~/.openclaw/openclaw.json
sed -i "s|__OPENROUTER_API_KEY__|${OPENROUTER_API_KEY:-}|g" ~/.openclaw/openclaw.json
sed -i "s|__GEMINI_API_KEY__|${GEMINI_API_KEY:-}|g" ~/.openclaw/openclaw.json

echo "Making scripts executable..."
chmod +x start.sh stop.sh

echo "OpenClaw setup complete!"
echo ""
echo "--Next steps:"
echo "  1. Add your Telegram user ID to allowFrom in ~/.openclaw/openclaw.json"
echo "  2. Run: openclaw gateway run &"
echo "  3. Open port 18789 to access the dashboard (if needed)"
