#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "$0")" && pwd)"
DOMAIN="${1:-homygo.eu}"

if "$DIR/check_hsts.sh" "$DOMAIN"; then
  echo "✅ HSTS OK pour $DOMAIN"
else
  code=$?
  MSG="*HSTS ALERT* : \`$DOMAIN\`\nLe contrôle a *échoué* (code $code).\nVérifie HSTS (max-age, includeSubDomains, preload) et la redirection HTTP➜HTTPS."
  "$DIR/notify_telegram.sh" "$MSG" || true
  exit $code
fi
