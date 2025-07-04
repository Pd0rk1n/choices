#!/bin/bash

sudo pacman -Syu --noconfirm

sudo pacman -S --noconfirm --needed \
    base-devel bash-completion cmake dosfstools exfatprogs \
    firefox gcc git gvfs gvfs-mtp gvfs-smb htop linux-headers \
    logrotate lsd make man-db man-pages nano neofetch nodejs \
    noto-fonts noto-fonts-cjk noto-fonts-emoji npm ntfs-3g p7zip \
    pacman-contrib python python-pip qtile reflector rsync sdd \
    sddm ttf-dejavu ttf-liberation unrar unzip xdg-user-dirs \
    xdg-utils xfce4 xfce4-goodies xfce4-terminal xorg xorg-xinit \
    xterm zip

echo "done"

