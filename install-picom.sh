#!/usr/bin/env bash
set -euo pipefail

echo "[1/4] Instalando picom..."
sudo apt update
sudo apt install -y picom

echo "[2/4] Creando carpeta ~/.config ..."
mkdir -p "$HOME/.config"

echo "[3/4] Escribiendo configuración en ~/.config/picom.conf ..."
cat > "$HOME/.config/picom.conf" <<'EOF'
# Shadows
shadow = true;
shadow-radius = 8;
shadow-opacity = 0.6;
shadow-offset-x = -3;
shadow-offset-y = -3;
shadow-exclude = [
  "class_g ?= 'i3-frame'"
];

# Fading
fading = true;
fade-in-step = 0.03;
fade-out-step = 0.03;
fade-delta = 4;

# Transparency / Opacity
inactive-opacity = 1;
frame-opacity = 1.0;
inactive-opacity-override = false;
detect-client-opacity = true;
focus-exclude = [ "class_g = 'Cairo-clock'" ];
opacity-rule = [
  "90:class_g = 'URxvt'",
  "97:class_g = 'Anki'",
  "70:class_g = 'i3bar'"
];

# General settings
backend = "glx";
vsync = true;
mark-wmwin-focused = true;
mark-ovredir-focused = true;
detect-rounded-corners = true;
detect-client-opacity = true;
# refresh-rate = 75;
use-ewmh-active-win = true;
detect-transient = true;
detect-client-leader = true;
use-damage = true;
log-level = "warn";

wintypes:
{
  tooltip = { fade = true; shadow = true; opacity = 1; focus = true; full-shadow = false; };
  dock = { shadow = false; opacity: 0.8; }
  dnd = { shadow = false; }
  popup_menu = { opacity = 0.8; }
  dropdown_menu = { opacity = 1; }
};

unredir-if-possible = false;

blur-background = true;
blur-method = "dual_kawase";
blur-strength = 1;

shadow-exclude = [
  "class_g = 'Conky'",
  "class_g = 'conky'",
  "name = 'conky'",
  "_NET_WM_NAME = 'conky'",
  "window_type = 'dock'",
  "window_type = 'desktop'",
  "window_type = 'utility'",
  "window_type = 'override'"
];
EOF

chmod 644 "$HOME/.config/picom.conf"

echo "[4/4] Listo."
echo "Para probar ahora:"
echo "  picom --config \$HOME/.config/picom.conf &"
echo "Para i3 (~/.config/i3/config):"
echo "  exec_always --no-startup-id picom --config \$HOME/.config/picom.conf"
