#!/usr/bin/env bash
set -euo pipefail

need_cmd() { command -v "$1" >/dev/null 2>&1; }

if ! need_cmd pacman; then
  echo "[ERROR] Este script está pensado para Arch Linux (pacman)."
  exit 1
fi

PKGS=(
  conky
  lm_sensors
  smartmontools
  iproute2
  curl
  jq
  git
)

NET_IF="enp2s0"
CPU_HWMON="coretemp"
CPU_TEMP_ID="temp 1"

echo "[1/4] Actualizando sistema e instalando paquetes..."
# sudo pacman -Syu --noconfirm
sudo pacman -S --needed --noconfirm "${PKGS[@]}"

echo "[2/4] Creando carpeta de configuración..."
mkdir -p "$HOME/.config/conky"

echo "[3/4] Generando ~/.config/conky/conky.conf ..."
tmp="$(mktemp)"
cat > "$tmp" <<CONF
conky.config = {
  alignment = 'top_right',
  background = false,
  border_width = 0,
  cpu_avg_samples = 4,
  default_color = 'white',
  default_outline_color = 'grey',
  default_shade_color = 'black',
  draw_borders = false,
  draw_graph_borders = false,
  draw_outline = false,
  draw_shades = false,
  use_xft = true,
  font = 'OpenSans:size=10',
  gap_x = 30,
  gap_y = 60,
  maximum_width = 300,
  minimum_height = 5,
  minimum_width = 5,
  net_avg_samples = 2,
  double_buffer = true,
  out_to_console = false,
  out_to_stderr = false,
  extra_newline = false,
  own_window = true,
  own_window_class = 'Conky',
  own_window_transparent = true,
  own_window_argb_visual = false,
  own_window_type = 'override',
  own_window_hints = 'undecorated,below,sticky,skip_taskbar,skip_pager',
  stippled_borders = 0,
  update_interval = 1,
  uppercase = false,
  use_spacer = 'none',
  show_graph_scale = false,
  show_graph_range = false
}

conky.text = [[
\${alignc}\${font Symbols Nerd Font:size=26}\${color #1793D1}\${font OpenSans:size=20}\${color #1793D1} Arch\${color Ivory}linux
\${voffset -90}
\${color DimGray}
\${font}
\${font OxygenSans:pixelsize=20}\$alignc\${time %A} \${color white}\${time %d}-\${color CDE0E7}\${time  %b}-\${color white}\${time %Y}\${font}

\${font OpenSans:bold:size=10}\${color #1793D1}SYSTEM \${color White} \${hr 2}
\$font\${color White}\$sysname \$kernel \$alignr \$machine
Frequency \$alignr\${freq_g cpu0}Ghz
Uptime \$alignr\${uptime}
File System \$alignr\${fs_type}

\${font OpenSans:bold:size=10}\${color #1793D1}CPU \${color White}\${hr 2}
\$font\${color White}Temperature: \$alignr \${hwmon ${CPU_HWMON} ${CPU_TEMP_ID}}°C
\$font\${color White}CPU1 \${cpu cpu1}% \${cpubar cpu1}
CPU2 \${cpu cpu2}% \${cpubar cpu2}
CPU3 \${cpu cpu3}% \${cpubar cpu3}
CPU4 \${cpu cpu4}% \${cpubar cpu4}
CPU5 \${cpu cpu5}% \${cpubar cpu5}
CPU6 \${cpu cpu6}% \${cpubar cpu6}
CPU7 \${cpu cpu7}% \${cpubar cpu7}
CPU8 \${cpu cpu8}% \${cpubar cpu8}
\${cpugraph White} \$color

\${font OpenSans:bold:size=10}\${color #1793D1}MEMORY \${color White}\${hr 2}
\$font\${color White}MEM \$alignc \$mem / \$memmax \$alignr \$memperc%
\$membar
\$font\${color White}SWAP \$alignc \$swap / \$swapmax \$alignr \$swapperc%
\$swapbar

\${font OpenSans:bold:size=10}\${color #1793D1}HDD \${color White}\${hr 2}
\$font\${color White}/home \$alignc \${fs_used /home} / \${fs_size /home} \$alignr \${fs_free_perc /home}%
\${fs_bar /home}

\${font OpenSans:bold:size=10}\${color #1793D1}NETWORK \${color White}\${hr 2}
\$font\${color White}IP Address: \$alignr \${addr ${NET_IF}}
\${hr 2}
Down \$alignr \${downspeed ${NET_IF}} kb/s
Up \$alignr \${upspeed ${NET_IF}} kb/s
\${hr 2}
Downloaded: \$alignr \${totaldown ${NET_IF}}
Uploaded: \$alignr \${totalup ${NET_IF}}

]]
CONF

dest="$HOME/.config/conky/conky.conf"

echo "[4/4] Aplicando configuración..."
if [[ -f "$dest" ]] && cmp -s "$tmp" "$dest"; then
  echo " - conky.conf ya estaba actualizado (sin cambios)."
  rm -f "$tmp"
  echo "[OK] Listo."
  echo "Prueba: conky -c ~/.config/conky/conky.conf &"
  exit 0
fi

cp "$tmp" "$dest"
rm -f "$tmp"

echo " - conky.conf escrito/actualizado en: $dest"
echo "[OK] Listo."
echo "Prueba: conky -c ~/.config/conky/conky.conf &"