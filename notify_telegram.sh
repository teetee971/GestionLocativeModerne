#!/usr/bin/env bash
set -euo pipefail
: "${TELEGRAM_BOT_TOKEN:?export TELEGRAM_BOT_TOKEN=...}"
: "${TELEGRAM_CHAT_ID:?export TELEGRAM_CHAT_ID=...}"

MSG="${1:?message manquant}"

curl -sS -X POST "https://api.telegram.org/bot${TELEGRAM_BOT_TOKEN}/sendMessage" \
  -d chat_id="${TELEGRAM_CHAT_ID}" \
  -d text="${MSG}" \
  -d parse_mode=Markdown >/dev/null
echo "✅ Notification envoyée."
