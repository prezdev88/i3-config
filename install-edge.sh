#!/usr/bin/env bash
set -euo pipefail

if [[ "${EUID}" -ne 0 ]]; then
  echo "Ejecuta como root (ej: sudo $0)"
  exit 1
fi

ARCH="$(dpkg --print-architecture)"
if [[ "$ARCH" != "amd64" ]]; then
  echo "Este instalador está pensado para amd64. Arquitectura detectada: $ARCH"
  echo "Si estás en arm64, puede que no exista paquete estable para tu distro/arquitectura."
  exit 1
fi

echo "[1/5] Instalando dependencias..."
apt-get update -y
apt-get install -y curl gpg ca-certificates

echo "[2/5] Configurando keyring de Microsoft..."
install -d -m 0755 /etc/apt/keyrings
curl -fsSL https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > /etc/apt/keyrings/microsoft.gpg
chmod 0644 /etc/apt/keyrings/microsoft.gpg

echo "[3/5] Configurando repositorio de Microsoft Edge (stable)..."
cat > /etc/apt/sources.list.d/microsoft-edge.list <<'EOF'
deb [arch=amd64 signed-by=/etc/apt/keyrings/microsoft.gpg] https://packages.microsoft.com/repos/edge stable main
EOF

echo "[4/5] Actualizando índices e instalando microsoft-edge-stable..."
apt-get update -y
apt-get install -y microsoft-edge-stable

echo "[5/5] Listo. Versión instalada:"
microsoft-edge --version || true

echo "Puedes abrirlo con: microsoft-edge"
