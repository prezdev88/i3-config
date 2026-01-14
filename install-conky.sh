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
  alignment = 'top_right',
  background = false,
  border_width = 0.5,
  cpu_avg_samples = 4,
  default_color = 'white',
  default_outline_color = 'grey',
  default_shade_color = 'black',
  draw_borders = true,
  draw_graph_borders = true,
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
  own_window_colour = '000000',
  own_window_class = 'Conky',
  own_window_argb_visual = true,
  own_window_type = 'override',
  own_window_transparent = true,
  own_window_hints = 'undecorated,below,sticky,skip_taskbar,skip_pager',
  stippled_borders = 0,
  update_interval = 1,
  uppercase = false,
  use_spacer = 'none',
  show_graph_scale = false,
  show_graph_range = false
}

conky.text = [[
${font OpenSans:size=20}$alignc${color Tan1}Ubuntu${color Ivory} LINUX
${voffset -90} 
${color DimGray}
${font}
${font OxygenSans:pixelsize=20}$alignc${time %A} ${color white}${time %d}-${color CDE0E7}${time  %b}-${color white}${time %Y}${font}

${font OpenSans:bold:size=10}${color Tan1}SYSTEM ${color White} ${hr 2}
$font${color White}$sysname $kernel $alignr $machine
Frequency $alignr${freq_g cpu0}Ghz
Uptime $alignr${uptime}
File System $alignr${fs_type}

${font OpenSans:bold:size=10}${color Tan1}CPU ${color White}${hr 2}
#$font${color White}Temperature: $alignr ${acpitemp} °C
$font${color White}Temperature: $alignr ${hwmon 1 temp 1}°C
$font${color White}CPU1 ${cpu cpu1}% ${cpubar cpu1}
CPU2 ${cpu cpu2}% ${cpubar cpu2}
CPU3 ${cpu cpu3}% ${cpubar cpu3}
CPU4 ${cpu cpu4}% ${cpubar cpu4}
CPU5 ${cpu cpu5}% ${cpubar cpu5}
CPU6 ${cpu cpu6}% ${cpubar cpu6}
CPU7 ${cpu cpu7}% ${cpubar cpu7}
CPU8 ${cpu cpu8}% ${cpubar cpu8}
${cpugraph White} $color
${font OpenSans:bold:size=10}${color Tan1}MEMORY ${color White}${hr 2}
$font${color White}MEM $alignc $mem / $memmax $alignr $memperc%
$membar
$font${color White}SWAP $alignc $swap / $swapmax $alignr $swapperc%
$swapbar

${font OpenSans:bold:size=10}${color Tan1}HDD ${color White}${hr 2}
$font${color White}/home $alignc ${fs_used /home} / ${fs_size /home} $alignr ${fs_free_perc /home}%
${fs_bar /home}

${font OpenSans:bold:size=10}${color Tan1}TOP PROCESSES ${color White}${hr 2}
${color White}$font${top_mem name 2}${alignr}${top mem 2} %
$font${top_mem name 3}${alignr}${top mem 3} %
$font${top_mem name 4}${alignr}${top mem 4} %
$font${top_mem name 5}${alignr}${top mem 5} %

${font OpenSans:bold:size=10}${color Tan2}NETWORK ${color White}${hr 2}
$font${color White}IP Address: $alignr ${addr wlp1s0}
${hr 2}
Down $alignr ${downspeed wlp1s0} kb/s
Up $alignr ${upspeed wlp1s0} kb/s
${hr 2}
Downloaded: $alignr ${totaldown wlp1s0}
Uploaded: $alignr ${totalup wlp1s0}

]]
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
