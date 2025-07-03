#!/bin/bash

# DO NOT JUST RUN THIS. EXAMINE AND JUDGE. RUN AT YOUR OWN RISK.

installed_dir=$(dirname "$(readlink -f "$(basename "$(pwd)")")")

if grep -q "artix" /etc/os-release; then
  echo "Detected Artix Linux"
  sudo cp -v /etc/pacman.conf.nemesis /etc/pacman.conf

  config_block="
[nemesis_repo]
SigLevel = Never
Server = https://erikdubois.github.io/\$repo/\$arch

[chaotic-aur]
SigLevel = Required DatabaseOptional
Include = /etc/pacman.d/chaotic-mirrorlist
"
  echo "$config_block" | sudo tee -a /etc/pacman.conf > /dev/null
fi

if grep -q "rebornos" /etc/os-release; then
  echo "Detected RebornOS"
  sudo cp -v /etc/pacman.conf.nemesis /etc/pacman.conf

  config_block="
[nemesis_repo]
SigLevel = Never
Server = https://erikdubois.github.io/\$repo/\$arch

[chaotic-aur]
SigLevel = Required DatabaseOptional
Include = /etc/pacman.d/chaotic-mirrorlist
"
  echo "$config_block" | sudo tee -a /etc/pacman.conf > /dev/null
fi

if grep -q "archcraft" /etc/os-release; then
  echo "Detected Archcraft"
  sudo cp -v /etc/pacman.conf.nemesis /etc/pacman.conf

  config_block="
[nemesis_repo]
SigLevel = Never
Server = https://erikdubois.github.io/\$repo/\$arch

[chaotic-aur]
SigLevel = Required DatabaseOptional
Include = /etc/pacman.d/chaotic-mirrorlist
"
  echo "$config_block" | sudo tee -a /etc/pacman.conf > /dev/null
fi

if grep -q "CachyOS" /etc/os-release; then
  echo "Detected CachyOS"
  sudo cp -v /etc/pacman.conf.nemesis /etc/pacman.conf

  config_block="
[nemesis_repo]
SigLevel = Never
Server = https://erikdubois.github.io/\$repo/\$arch

[chaotic-aur]
SigLevel = Required DatabaseOptional
Include = /etc/pacman.d/chaotic-mirrorlist
"
  echo "$config_block" | sudo tee -a /etc/pacman.conf > /dev/null
fi

if grep -q "Manjaro" /etc/os-release; then
  echo "Detected Manjaro"
  sudo cp -v /etc/pacman.conf.nemesis /etc/pacman.conf

  config_block="
[nemesis_repo]
SigLevel = Never
Server = https://erikdubois.github.io/\$repo/\$arch

[chaotic-aur]
SigLevel = Required DatabaseOptional
Include = /etc/pacman.d/chaotic-mirrorlist
"
  echo "$config_block" | sudo tee -a /etc/pacman.conf > /dev/null
fi

if grep -q "Garuda" /etc/os-release; then
  echo "Detected Garuda"
  sudo cp -v /etc/pacman.conf.nemesis /etc/pacman.conf

  config_block="
[nemesis_repo]
SigLevel = Never
Server = https://erikdubois.github.io/\$repo/\$arch
"
  echo "$config_block" | sudo tee -a /etc/pacman.conf > /dev/null
fi

if grep -q "ArchBang" /etc/os-release; then
  echo "Detected ArchBang"

  [ ! -f "$HOME/.bash_profile_nemesis" ] && cp -vf "$HOME/.bash_profile" "$HOME/.bash_profile_nemesis"
  [ ! -f "$HOME/.xinitrc-nemesis" ] && cp -vf "$HOME/.xinitrc" "$HOME/.xinitrc-nemesis"
  [ ! -d "$HOME/.bin" ] && mkdir "$HOME/.bin"
  cp "/home/$USER/AB_Scripts/startpanel" "$HOME/.bin/startpanel"

  echo "Copying custom mirrorlist..."
  sudo cp mirrorlist /etc/pacman.d/mirrorlist

  echo "Skipping initramfs rebuild to avoid boot issues"
  # sudo sed -i 's/COMPRESSION="xz"/COMPRESSION="zstd"/g' /etc/mkinitcpio.conf
  # sudo mkinitcpio -P
fi

echo
tput setaf 6
echo "##############################################################"
echo "#####         700-intervention (safe version) done       #####"
echo "##############################################################"
tput sgr0

