#!/usr/bin/env python3

import json
import subprocess
from datetime import datetime, timezone
from pathlib import Path

STATE_PATH = Path.home() / ".openclaw/workspace/memory/heartbeat-state.json"
LOG_PATH   = Path("/tmp/reminder.log")

MAX_INACTIVE_MINUTES = 30  # stop reminding

def log(msg):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    line = f"{timestamp}: {msg}\n"
    print(line, end="")
    with open(LOG_PATH, "a") as f:
        f.write(line)

def load_state():
    if not STATE_PATH.exists():
        return None
    with open(STATE_PATH, encoding="utf-8") as f:
        return json.load(f)

def save_state(state):
    with open(STATE_PATH, "w", encoding="utf-8") as f:
        json.dump(state, f, indent=2)

def minutes_since(iso_timestamp):
    if not iso_timestamp or iso_timestamp == "null":
        return 9999
    try:
        dt = datetime.fromisoformat(iso_timestamp.replace("Z", "+00:00"))
        return int((datetime.now(timezone.utc) - dt).total_seconds() / 60)
    except Exception as e:
        log(f"Timestamp error: {e}")
        return 9999

def pick_message(topics):
    minute = datetime.now().minute
    if topics and len(topics) > 0:
        topic = topics[-1]
        messages = [
            f"Still there? Quick quiz ready on {topic}! 📚",
            f"Hi! Want to test yourself on {topic}? Only 5 minutes! ⚡",
        ]
    else:
        messages = [
            "Still there? Want a quick 5-min quiz? 📚",
            "Hi! Quick review now locks it in. Quiz time? ⚡",
        ]
    return messages[minute % 2]

def send_reminder(message, chat_id):
    cmd = [
        "openclaw", "cron", "add",
        "--name",            "reminder-oneshot",
        "--at",              "5s",
        "--session",         "isolated",
        "--message",         message,
        "--model",       "google/gemini-2.5-flash"
        "--light-context",
        "--announce",
        "--channel",         "telegram",
        "--to",          str(chat_id),
        "--delete-after-run"
    ]
    result = subprocess.run(cmd, capture_output=True, text=True)
    if result.returncode != 0:
        log(f"OpenClaw error: {result.stderr}")
    else:
        log(f"Reminder sent: {message}")

def main():
    log("-" * 40)

    state = load_state()
    if not state:
        log("No state file, skipping.")
        return
    chat_id = state.get("telegramChatId")
    if not chat_id or chat_id=="null" or chat_id=="__CHAT_ID__":
        log("No telegramChatId in state file, skipping.")
        log("Add CHAT_ID to your Codespace secrets and rebuild.")
        return

    if not state.get("sessionActive"):
        log("Session not active, skipping.")
        return

    last_msg = state.get("lastMessageReceived")
    if not last_msg or last_msg == "null":
        log("No message recorded yet, skipping.")
        return

    inactive_min = minutes_since(last_msg)
    log(f"Student inactive {inactive_min} min.")

    # Student still active
    if inactive_min < 5:
        log("Student active, skipping.")
        return

    # Student left = stop reminding + mark session inactive
    if inactive_min > MAX_INACTIVE_MINUTES:
        log(f"Over {MAX_INACTIVE_MINUTES} min — student left. Stopping reminders.")
        state["sessionActive"] = False
        save_state(state)
        return

    # Check cooldown between reminders
    cooldown     = state.get("cooldownMinutes", 30)
    last_rem     = state.get("lastReminderSent")
    since_remind = minutes_since(last_rem)

    if last_rem and last_rem != "null" and since_remind < cooldown:
        log(f"Cooldown active ({since_remind}/{cooldown} min), skipping.")
        return

    # All checks passed = send ONE reminder (only API call)
    message = pick_message(state.get("todayTopics", []))
    send_reminder(message, chat_id)

    state["lastReminderSent"] = datetime.now(timezone.utc).strftime("%Y-%m-%dT%H:%M:%S+00:00")
    state["reminderCount"]    = state.get("reminderCount", 0) + 1
    save_state(state)
    log("State updated.")

if __name__ == "__main__":
    main()