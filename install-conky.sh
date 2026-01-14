#!/usr/bin/env bash
set -euo pipefail

need_cmd() { command -v "$1" >/dev/null 2>&1; }

if ! need_cmd apt; then
  echo "[ERROR] Este script está pensado para Ubuntu/Debian (apt)."
  exit 1
fi

PKGS=(
  conky-all
  lm-sensors
  smartmontools
  iproute2
  curl
  jq
  git
)

echo "[1/4] Actualizando índices de paquetes..."
sudo apt update

echo "[2/4] Instalando dependencias y Conky..."
sudo apt install -y "${PKGS[@]}"

echo "[3/4] Creando carpeta de configuración..."
mkdir -p "$HOME/.config/conky"

echo "[4/4] Generando ~/.config/conky/conky.conf ..."
tmp="$(mktemp)"
cat > "$tmp" <<'CONF'
conky.config = {
  background = true,
  update_interval = 1,
  double_buffer = true,
  no_buffers = true,

  own_window = true,
  own_window_type = 'override',
  own_window_transparent = true,
  own_window_hints = 'undecorated,below,sticky,skip_taskbar,skip_pager',
  own_window_argb_visual = true,
  own_window_argb_value = 0,

  draw_shades = false,
  draw_outline = false,
  draw_borders = false,

  alignment = 'top_right',
  gap_x = 18,
  gap_y = 48,
  minimum_width = 320,
  maximum_width = 320,

  use_xft = true,
  font = 'DejaVu Sans:size=10',
  xftalpha = 1,

  uppercase = false,
  override_utf8_locale = true,

  color1 = 'FFFFFF',
  color2 = 'A0A0A0',
  color3 = '7AA2F7',
};

conky.text = [[
${color1}${font DejaVu Sans:bold:size=12}${nodename}${font}${color2}  ${time %H:%M}
${color2}${hr 1}

${color1}CPU${color2}  ${cpu cpu0}%  ${cpubar cpu0 8,170}
${color2}Freq:${color1} ${freq_g} GHz  ${color2}Load:${color1} ${loadavg}

${color1}RAM${color2}  ${mem} / ${memmax}  ${membar 8,170}

${color1}DISK${color2} ${fs_used /} / ${fs_size /}  ${fs_bar 8,170 /}
${color2}Free:${color1} ${fs_free /}

${color1}NET${color2}  ${if_up $default_iface}${color2}IP:${color1} ${addr $default_iface}
${color2}Down:${color1} ${downspeed $default_iface} ${color2}Up:${color1} ${upspeed $default_iface}
${color2}${downspeedgraph $default_iface 20,150} ${upspeedgraph $default_iface 20,150}
${else}${color2}Sin red activa${endif}

${color2}${hr 1}
${color1}TEMP${color2} CPU:${color1} ${execi 5 sensors | awk '/Package id 0|Tctl|CPU Temperature/ {print $4; exit}'}
${color2}Uptime:${color1} ${uptime}
]];
CONF

dest="$HOME/.config/conky/conky.conf"
if [[ -f "$dest" ]] && cmp -s "$tmp" "$dest"; then
  echo " - conky.conf ya estaba actualizado (sin cambios)."
  rm -f "$tmp"
  echo "[OK] Instalación y configuración terminada."
  echo "Prueba: conky -c ~/.config/conky/conky.conf &"
  exit 0
fi

cp "$tmp" "$dest"
rm -f "$tmp"

echo " - conky.conf escrito/actualizado en: $dest"
echo "[OK] Instalación y configuración terminada."
echo "Prueba: conky -c ~/.config/conky/conky.conf &"
