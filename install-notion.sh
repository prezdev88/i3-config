#!/usr/bin/env bash
set -euo pipefail

APP_URL="https://www.notion.so"

echo "[1/3] Buscando Chromium..."
CHROMIUM_BIN=""

if command -v chromium >/dev/null 2>&1; then
  CHROMIUM_BIN="$(command -v chromium)"
elif command -v chromium-browser >/dev/null 2>&1; then
  CHROMIUM_BIN="$(command -v chromium-browser)"
else
  echo "No encontré Chromium (chromium o chromium-browser)."
  echo "Instálalo primero, por ejemplo:"
  echo "  sudo apt update && sudo apt install -y chromium-browser"
  exit 1
fi

echo "Usando: $CHROMIUM_BIN"

echo "[2/3] Creando /usr/bin/notion ..."
TMP_FILE="$(mktemp)"

cat > "$TMP_FILE" <<EOF
#!/usr/bin/env bash
set -euo pipefail
exec "$CHROMIUM_BIN" --app="$APP_URL" "\$@"
EOF

sudo install -m 755 "$TMP_FILE" /usr/bin/notion
sudo chown root:root /usr/bin/notion
rm -f "$TMP_FILE"

echo "[3/3] Listo."
echo "Ejecuta: notion"
