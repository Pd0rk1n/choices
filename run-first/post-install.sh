#!/bin/bash
# Arch Linux post-install with SDDM + startx fallback, autologin, logging, and modular control

LOG_FILE="/var/log/post_install.log"
PACKAGE_LIST="./packages.conf"
USERNAME=$(logname)
USER_HOME="/home/$USERNAME"
XINITRC="$USER_HOME/.xinitrc"
AUTOLOGIN_SERVICE="/etc/systemd/system/getty@tty1.service.d/override.conf"

# Colors
info()  { echo -e "\e[1;34m[INFO]\e[0m $1" | tee -a "$LOG_FILE"; }
warn()  { echo -e "\e[1;33m[WARN]\e[0m $1" | tee -a "$LOG_FILE"; }
fail()  { echo -e "\e[1;31m[FAIL]\e[0m $1" | tee -a "$LOG_FILE"; exit 1; }

# === Dry Run Option ===
read -rp "Run in dry mode (no changes)? [y/N]: " dry
DRY=false
[[ "$dry" =~ ^[Yy]$ ]] && DRY=true && info "Dry mode enabled. No changes will be made."

# === Root Check ===
[[ $EUID -ne 0 ]] && fail "Run this script as root."

# === Section Selector ===
echo -e "\nSelect sections to run:"
read -rp "Install packages? [Y/n]: " pkg
read -rp "Enable SDDM? [Y/n]: " sddm
read -rp "Configure .xinitrc for startx? [Y/n]: " xinit
read -rp "Enable TTY1 autologin fallback? [Y/n]: " autologin

# === PACKAGE INSTALL ===
if [[ ! "$pkg" =~ ^[Nn]$ ]]; then
    info "Installing packages from $PACKAGE_LIST..."
    if [[ "$DRY" = false ]]; then
        pacman -Sy --noconfirm --needed $(grep -vE '^\s*#' "$PACKAGE_LIST" | tr '\n' ' ')
    else
        grep -vE '^\s*#' "$PACKAGE_LIST" | tr '\n' ' '
    fi
fi

# === ENABLE SDDM ===
if [[ ! "$sddm" =~ ^[Nn]$ ]]; then
    info "Enabling SDDM..."
    $DRY || systemctl enable sddm.service
fi

# === CONFIGURE .XINITRC ===
if [[ ! "$xinit" =~ ^[Nn]$ ]]; then
    info "Creating or updating $XINITRC for startx fallback..."

    xcmd="exec startxfce4"
    $DRY || {
        if pacman -Q xfce4 &>/dev/null; then xcmd="exec startxfce4"
        elif pacman -Q qtile &>/dev/null; then xcmd="exec qtile start"
        elif pacman -Q plasma-meta &>/dev/null; then xcmd="exec startplasma-x11"
        elif pacman -Q gnome &>/dev/null; then xcmd="exec gnome-session"
        fi

        echo "$xcmd" > "$XINITRC"
        chown "$USERNAME:$USERNAME" "$XINITRC"
        chmod +x "$XINITRC"
    }
fi

# === ENABLE AUTOLOGIN TO TTY1 ===
if [[ ! "$autologin" =~ ^[Nn]$ ]]; then
    info "Setting up autologin on tty1 for fallback..."

    if [[ "$DRY" = false ]]; then
        mkdir -p "$(dirname "$AUTOLOGIN_SERVICE")"
        cat > "$AUTOLOGIN_SERVICE" <<EOF
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin $USERNAME --noclear %I \$TERM
EOF
        systemctl daemon-reexec
        systemctl restart getty@tty1
        info "Autologin on tty1 enabled for user '$USERNAME'."
    else
        echo "Would create: $AUTOLOGIN_SERVICE"
        echo "[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin $USERNAME --noclear %I \$TERM"
    fi
fi

# === DONE ===
info "Post-install script completed."
info "Log saved to $LOG_FILE"

# === REBOOT PROMPT ===
read -rp "Reboot now? [y/N]: " reboot
if [[ "$reboot" =~ ^[Yy]$ ]]; then
    info "Rebooting system..."
    reboot
else
    info "Reboot skipped. You may want to reboot manually later."
fi
