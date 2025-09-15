#!/usr/bin/env bash
set -euo pipefail

DOMAIN="${1:-homygo.eu}"
MIN_MAXAGE=31536000    # 1 an minimum

fail(){ echo "❌ $*"; exit 1; }
ok(){   echo "✅ $*"; }

# 1) Récupération des headers
HDRS="$(curl -sI "https://${DOMAIN}" || true)"
[[ -n "$HDRS" ]] || fail "Impossible d’atteindre https://${DOMAIN}"

# 2) Vérif HSTS
STS_LINE="$(grep -i '^Strict-Transport-Security:' <<< "$HDRS" || true)"
[[ -n "$STS_LINE" ]] || fail "Header HSTS manquant"

MAXAGE="$(sed -n 's/.*max-age=\([0-9]\+\).*/\1/ip' <<< "$STS_LINE" | tr -d '\r' | tail -n1)"
[[ -n "$MAXAGE" ]] || fail "max-age introuvable"
(( MAXAGE >= MIN_MAXAGE )) || fail "max-age trop faible (${MAXAGE})"

grep -qi 'includesubdomains' <<< "$STS_LINE" || fail "includeSubDomains absent"
grep -qi 'preload' <<< "$STS_LINE" || fail "preload absent"

ok "Header HSTS OK : ${STS_LINE}"

# 3) Vérif redirection HTTP → HTTPS
HTTP_HDRS="$(curl -sI "http://${DOMAIN}" || true)"
if grep -qiE '^HTTP/.* (301|308)' <<< "$HTTP_HDRS" && grep -qi 'Location: https://' <<< "$HTTP_HDRS"; then
  ok "Redirection HTTP ➜ HTTPS correcte"
else
  fail "Redirection HTTP ➜ HTTPS non correcte"
fi
