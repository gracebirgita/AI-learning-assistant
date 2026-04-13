# AI-learning-assistant
<br>

[![Open in your GitHub Codespaces](https://github.com/codespaces/badge.svg)](https://codespaces.new/YOUR_USERNAME/openclaw-student-template)

<br>

## Setup for codespaces
1. Fork this repo
2. Go to your fork →  **Settings → Secrets and variables → Codespaces**
3. Add these secrets:

| Secret | Where to get it |
|--------|----------------|
| `TELEGRAM_BOT_TOKEN` | From @BotFather on Telegram |
| `OPENROUTER_API_KEY` | From [openrouter.ai](https://openrouter.ai) — look for models labeled **(free)** |
| `GEMINI_API_KEY` | From [aistudio.google.com](https://aistudio.google.com) |
| `TAVILY_API_KEY` | From [tavily.com](https://tavily.com) — (optional) web searching |
| `CHAT_ID` | Message @userinfobot on Telegram |

> You can only add **one** of `OPENROUTER_API_KEY` or `GEMINI_API_KEY` to get started.
>
> You can add Tavily if you want to add web searching skill (free tier | without credit card registration) 

---

### Get Telegram Bot Token
- Open Telegram → search @BotFather
- Send /newbot
- Follow prompts (pick a name and **unique** username)
- Copy the token (looks like 123456789:ABCdef...)
- Paste it into your GitHub Codespaces secret

---
<br>

## Start bot (learning assistant)

4. Create a Codespace → the setup runs automatically
   > Wait for the setup to finish — you'll see **"OpenClaw setup complete!"** in the terminal
   * if postSetupCommands failed, in terminal run:

     ```bash .devcontainer/setup.sh```
5. Open the terminal if it's not already visible
   > Go to **Terminal → New Terminal** in the top menu
6. Start your bot by typing:

   ```bash start.sh```
   > You should see: **"OpenClaw is running! Your Telegram bot is now active."**
8. Open Telegram and message your bot to test it

## Stop bot

When you're done, type this in the terminal:

```bash stop.sh```

<br>

## Add Telegram user ID (first time only)
By default your bot won't respond to anyone until you whitelist yourself.

- Message your bot on Telegram. If it's won't reply yet, in the terminal, run:

  ```openclaw logs --follow```
- Look for a line with `from.id` (that number is your Telegram user ID)
- Press **Ctrl + C** to stop the logs
- Run this (replace `YOUR_ID` with the number you found):

  `openclaw config set channels.telegram.allowFrom '["YOUR_ID"]'`
- Restart the bot:

  `bash stop.sh && bash start.sh`
- Message your bot again, it should now reply!
