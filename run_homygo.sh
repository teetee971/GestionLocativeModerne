#!/data/data/com.termux/files/usr/bin/bash
set -euo pipefail

PROJECT="homygo-site"         # <- nom Cloudflare Pages
OUTDIR="dist"
ZIP="homygo-dist-$(date +%F-%H%M).zip"

echo "🧹 Nettoyage…"
rm -rf "$OUTDIR" *.zip 2>/dev/null || true

echo "📦 Build Vite…"
# Build en sortie dans dist/
npx vite build --outDir "$OUTDIR" --emptyOutDir

echo "🛡️  Copie des fichiers racine utiles…"
cp -a _headers _redirects robots.txt sitemap.xml manifest.webmanifest sw.js health.txt "$OUTDIR"/ 2>/dev/null || true
# Icônes PWA si dossier icons/ existe
[ -d icons ] && mkdir -p "$OUTDIR/icons" && cp -a icons/* "$OUTDIR/icons/"

echo "🔍 Contrôles rapides…"
test -f "$OUTDIR/index.html" || { echo "❌ index.html manquant"; exit 1; }
grep -qi '<title>' "$OUTDIR/index.html" || echo "⚠️  Pas de <title> trouvé dans index.html"
ls -lh "$OUTDIR" | sed 's/^/   /'

echo "🗜️  Création du ZIP pour upload manuel…"
rm -f homygo-dist-*.zip
zip -r "$ZIP" "$OUTDIR" >/dev/null
echo "✅ Archive créée: $ZIP"

# ---------- Déploiement automatique (si wrangler dispo) ----------
if command -v wrangler >/dev/null 2>&1; then
  echo "☁️  Tentative de déploiement Cloudflare Pages (wrangler)…"
  # Vérifier connexion (wrangler login a déjà été fait une fois)
  if wrangler whoami >/dev/null 2>&1; then
    wrangler pages deploy "$OUTDIR" --project-name "$PROJECT"
    echo "✅ Déploiement Pages terminé."
  else
    echo "⚠️  wrangler non connecté. Lance:  wrangler login"
    echo "   Puis relance:  ./run_homygo.sh"
  fi
else
  echo "ℹ️  wrangler non installé. Pour activer le déploiement auto :"
  echo "   npm install -g wrangler && wrangler login"
fi

echo
echo "📤 Si tu préfères l’upload manuel Cloudflare Pages:"
echo "   1) Ouvre Pages > ${PROJECT} > Gérer le déploiement > Déployer via upload"
echo "   2) Choisis le fichier: $ZIP"
echo "   (ou crée le projet si pas encore fait)"
