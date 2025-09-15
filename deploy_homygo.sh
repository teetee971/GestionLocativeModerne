#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

# ====== CONFIG ======
USERNAME="teetee971"
REPO="GestionLocativeModerne"
TARGET_BRANCH="homygo-pwa"     # branche de déploiement "safe"
COMMIT_MSG="🚀 Homygo PWA deploy $(date '+%Y-%m-%d %H:%M:%S')"
# ====================

echo "🚀 Déploiement HOMYGO → ${USERNAME}/${REPO} (branche ${TARGET_BRANCH})"

# 1) Récupérer le token (préférer variable d'env pour éviter toute saisie)
if [ "${GITHUB_TOKEN:-}" = "" ]; then
  read -rsp "🔑 Colle ton GitHub Personal Access Token (masqué) : " GITHUB_TOKEN
  echo
fi
[ -n "$GITHUB_TOKEN" ] || { echo "❌ Token vide"; exit 1; }

# 2) Init repo local propre (sans garder le token en remote)
rm -rf .git
git init
git config user.name "TermuxBot"
git config user.email "${USERNAME}@users.noreply.github.com"
git checkout -b "$TARGET_BRANCH"

# 3) Commit
git add -A
git commit -m "$COMMIT_MSG"

# 4) Push SANS enregistrer de remote (le token n'est pas sauvegardé)
PUSH_URL="https://${USERNAME}:${GITHUB_TOKEN}@github.com/${USERNAME}/${REPO}.git"
echo "⬆️  Push vers GitHub…"
git push -u "$PUSH_URL" HEAD:"$TARGET_BRANCH"

echo "✅ Push GitHub terminé."

# 5) (Optionnel) Déploiement Cloudflare via Wrangler si présent
if command -v wrangler >/dev/null 2>&1; then
  echo "🌐 Publication Cloudflare Pages (wrangler)…"
  wrangler pages publish . --project-name="homygo" || echo "ℹ️ Etape wrangler sautée/échouée."
fi

echo "🎉 Fini."
