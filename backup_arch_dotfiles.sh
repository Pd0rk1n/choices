#!/bin/bash

set -euo pipefail

# === Config ===
DATE=$(date +"%Y%m%d")
BACKUP_DIR="$HOME/backups/arch-dotfiles-$DATE"
LOG_FILE="$BACKUP_DIR/backup.log"

DOTFILES=(
  ".bashrc"
  ".zshrc"
  ".zshrc-nemesis"
  ".ssh"
  ".gnupg"
  ".face"
  ".screenrc"
  ".fonts"
  ".icons"
  ".xsessionrc"
  ".local"
  ".bashrc-nemesis"
  ".dmrc"
  ".gitconfig"
  ".gtkrc-2.0"
  ".xinitrc"
  ".Xresources"
  ".xprofile"
  ".themes"
  ".config"
  ".config/xfce"
  ".config/gtk-3.0"
)

SECURE_DIRS=(
  ".ssh"
  ".gnupg"
)

CONFIG_DIR="$HOME/.config"
FONTS_DIR="$HOME/.local/share/fonts"

# === Progress Bar Function ===
show_progress() {
  local current=$1
  local total=$2
  local label="$3"
  local percent=$(( current * 100 / total ))
  local bars=$(( percent / 10 ))
  local empty=$(( 10 - bars ))

  bar=$(printf "%0.s#" $(seq 1 $bars))
  space=$(printf "%0.s " $(seq 1 $empty))
  printf "==> %-25s [%s%s] (%3d%%)\n" "$label" "$bar" "$space" "$percent"
}

# === Create Backup Directory ===
mkdir -p "$BACKUP_DIR"

echo "📦 Saving package list..."
pacman -Qqe > "$BACKUP_DIR/pacman-packages.txt"
if command -v yay &>/dev/null; then
  yay -Qqe > "$BACKUP_DIR/aur-packages.txt"
else
  echo "⚠️ yay not found — skipping AUR list"
  touch "$BACKUP_DIR/aur-packages.txt"
fi

# === Copy Dotfiles with Progress ===
echo ""
echo "🔄 Copying dotfiles..."
total=${#DOTFILES[@]}
i=0
for file in "${DOTFILES[@]}"; do
  i=$((i + 1))
  show_progress "$i" "$total" "$file"
  [[ -f "$HOME/$file" ]] && cp -v "$HOME/$file" "$BACKUP_DIR/" >> "$LOG_FILE" 2>&1 || echo "⚠️ Missing $file" >> "$LOG_FILE"
done

# === Copy .config Directory ===
echo ""
echo "📁 Copying .config..."
if [[ -d "$CONFIG_DIR" ]]; then
  rsync -a "$CONFIG_DIR/" "$BACKUP_DIR/.config/" >> "$LOG_FILE" 2>&1
  show_progress 1 1 ".config"
else
  echo "⚠️ .config directory missing" >> "$LOG_FILE"
fi

# === Copy Fonts ===
echo ""
echo "🔤 Copying fonts..."
if [[ -d "$FONTS_DIR" ]]; then
  rsync -a "$FONTS_DIR/" "$BACKUP_DIR/fonts/" >> "$LOG_FILE" 2>&1
  show_progress 1 1 "fonts"
else
  echo "⚠️ fonts missing" >> "$LOG_FILE"
fi

# === Copy Secure Dirs ===
echo ""
echo "🔐 Copying secure dirs..."
total=${#SECURE_DIRS[@]}
i=0
for dir in "${SECURE_DIRS[@]}"; do
  i=$((i + 1))
  show_progress "$i" "$total" "$dir"
  if [[ -d "$HOME/$dir" ]]; then
    rsync -a "$HOME/$dir/" "$BACKUP_DIR/$dir/" --chmod=700 >> "$LOG_FILE" 2>&1
  else
    echo "⚠️ $dir missing" >> "$LOG_FILE"
  fi
done

# === Done ===
echo ""
echo "✅ Backup complete!"
echo "📂 Saved to: $BACKUP_DIR"
echo "📝 Log: $LOG_FILE"
