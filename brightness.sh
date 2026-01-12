#!/usr/bin/env bash
set -euo pipefail

RULE_FILE="/etc/udev/rules.d/90-backlight.rules"
RULE_CONTENT='ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="*", RUN+="/bin/chgrp video /sys/class/backlight/%k/brightness"
ACTION=="add", SUBSYSTEM=="backlight", KERNEL=="*", RUN+="/bin/chmod g+w /sys/class/backlight/%k/brightness"'

if [[ "${EUID}" -ne 0 ]]; then
    echo "Este script debe ejecutarse como root. Ejemplo: sudo $0"
    exit 1
fi

TARGET_USER="${SUDO_USER:-}"
if [[ -z "${TARGET_USER}" ]]; then
    echo "No se pudo detectar el usuario (SUDO_USER vacío)."
    echo "Ejecuta el script así: sudo ./setup-brightness-perms.sh"
    exit 1
fi

echo "==> Instalando brightnessctl (si hace falta)..."
apt-get update -y
apt-get install -y brightnessctl

echo "==> Verificando /sys/class/backlight..."
if [[ ! -d /sys/class/backlight ]] || [[ -z "$(ls -A /sys/class/backlight 2>/dev/null || true)" ]]; then
    echo "No se encontró /sys/class/backlight (o está vacío)."
    echo "Puede que tu equipo no exponga backlight por esta vía."
    exit 1
fi

echo "==> Dispositivos backlight detectados:"
ls -1 /sys/class/backlight

echo "==> Creando regla udev en: ${RULE_FILE}"
printf "%s\n" "${RULE_CONTENT}" > "${RULE_FILE}"
chmod 0644 "${RULE_FILE}"

echo "==> Agregando usuario '${TARGET_USER}' al grupo 'video'..."
usermod -aG video "${TARGET_USER}"

echo "==> Recargando reglas udev..."
udevadm control --reload-rules

echo "==> Disparando udev para backlight..."
udevadm trigger -s backlight

echo
echo "Listo."
echo "IMPORTANTE: cierra sesión y vuelve a entrar para que '${TARGET_USER}' tome el grupo 'video'."
echo
echo "Luego prueba (sin sudo):"
echo "  brightnessctl -c backlight set 10%-"
echo "  brightnessctl -c backlight set 10%+"
