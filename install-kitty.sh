#!/usr/bin/env bash
set -euo pipefail

echo "[1/3] Instalando kitty..."
sudo apt update
sudo apt install -y kitty

echo "[2/3] Creando configuración de kitty..."
mkdir -p "$HOME/.config/kitty"

cat > "$HOME/.config/kitty/kitty.conf" <<'EOF'
# Kitty config (generated)
font_size 14.0
EOF

echo "[3/3] Listo."
echo "Abre kitty y deberías ver font_size 14.0."
echo "Si kitty ya estaba abierto, puedes recargar con Ctrl+Shift+F5."
