#!/bin/bash
# Vérification automatique du site Homygo

URL="https://homygo.eu"
CHECK="Homygo fonctionne ✅"

echo "🔍 Vérification du site $URL ..."

# On récupère le contenu de la page
CONTENT=$(curl -s "$URL")

# On cherche la phrase de validation
if echo "$CONTENT" | grep -q "$CHECK"; then
    echo "✅ Le site est en ligne et fonctionne correctement."
    exit 0
else
    echo "❌ Attention : le contenu attendu n'a pas été trouvé !"
    echo "👉 Vérifie si le déploiement a bien eu lieu."
    exit 1
fi
