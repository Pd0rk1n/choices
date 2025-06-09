#!/bin/bash

set -e  # Exit on any error

echo "🔧 Starting full dotfiles installation from: $(pwd)"
echo "-----------------------------------------------"

# === Step 1: Install user files (pd0rk1n/) ===
if [ -f ./install_pd0rk1n_user_files.sh ]; then
  echo "🧰 Step 1: Installing user files from pd0rk1n/..."
  bash ./install_pd0rk1n_user_files.sh
else
  echo "⚠️  Skipping: install_pd0rk1n_user_files.sh not found."
fi

# === Step 2: Install user config files (.config/) ===
if [ -f ./install_config.sh ]; then
  echo "🧩 Step 2: Installing .config files..."
  bash ./install_config.sh
else
  echo "⚠️  Skipping: install_config.sh not found."
fi

# === Step 3: Install system-wide themes (/usr/share/themes) ===
if [ -f ./install_themes.sh ]; then
  echo "🎨 Step 3: Installing system themes..."
  bash ./install_themes.sh
else
  echo "⚠️  Skipping: install_themes.sh not found."
fi

echo "✅ All steps completed. Your system should now be set up!"
