---
name: reminder
description: Checks student inactivity and sends Telegram study reminder. Zero API tokens for the check itself.
---

# Reminder Skill

Runs every 5 minutes via system crontab.
Only calls OpenClaw when student inactive 5-30 minutes.
Stops automatically after 30 minutes (student has left).