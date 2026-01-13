#!/usr/bin/env bash
set -euo pipefail

echo "[1/6] Instalando paquetes..."
sudo apt update
sudo apt install -y zsh git curl fonts-powerline

echo "[2/6] Instalando Oh My Zsh (sin modo interactivo)..."
export RUNZSH=no
export CHSH=no
export KEEP_ZSHRC=yes

if [ ! -d "$HOME/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
else
  echo "Oh My Zsh ya está instalado. Saltando..."
fi

echo "[3/6] Configurando tema agnoster en ~/.zshrc ..."
ZSHRC="$HOME/.zshrc"
if [ ! -f "$ZSHRC" ]; then
  touch "$ZSHRC"
fi

if grep -q '^ZSH_THEME=' "$ZSHRC"; then
  sed -i 's/^ZSH_THEME=.*/ZSH_THEME="agnoster"/' "$ZSHRC"
else
  echo 'ZSH_THEME="agnoster"' >> "$ZSHRC"
fi

echo "[4/6] Asegurando que Oh My Zsh se cargue en ~/.zshrc ..."
if ! grep -q 'source \$ZSH/oh-my-zsh.sh' "$ZSHRC"; then
  cat >> "$ZSHRC" <<'EOF'

export ZSH="$HOME/.oh-my-zsh"
source $ZSH/oh-my-zsh.sh
EOF
fi

echo "[5/6] Dejando zsh como shell por defecto para $USER ..."
chsh -s "$(command -v zsh)"

echo "[6/6] Listo."
echo "Cierra sesión y vuelve a entrar para que el cambio de shell aplique."
echo "Luego abre tu terminal: deberías ver agnoster."
