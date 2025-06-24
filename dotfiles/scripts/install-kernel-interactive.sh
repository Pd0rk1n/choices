#!/bin/bash
set -e

# ========================
# 💬 Interactive Kernel Menu
# ========================
echo "🔧 Select a kernel to install:"
kernels=("linux" "linux-lts" "linux-zen" "linux-hardened" "Quit")
select KERNEL in "${kernels[@]}"; do
  if [[ "$KERNEL" == "Quit" ]]; then
    echo "👋 Exiting."
    exit 0
  elif [[ -n "$KERNEL" ]]; then
    echo "✅ You selected: $KERNEL"
    break
  fi
done

KERNEL_DISPLAY="Arch Linux (${KERNEL#linux-})"
[[ "$KERNEL" == "linux" ]] && KERNEL_DISPLAY="Arch Linux"

# ========================
# 📦 Install Kernel & Headers
# ========================
echo "📦 Installing $KERNEL kernel and headers..."
sudo pacman -Syu --noconfirm "$KERNEL" "${KERNEL}-headers"

# ========================
# 🔍 Detect Root UUID
# ========================
ROOT_UUID=$(findmnt / -no UUID)
echo "➡️  Root UUID: $ROOT_UUID"

# ========================
# 🧭 Detect Bootloader
# ========================
if [[ -d /boot/loader/entries ]]; then
  BOOTLOADER="systemd-boot"
elif [[ -f /boot/grub/grub.cfg ]]; then
  if [[ -d /sys/firmware/efi ]]; then
    BOOTLOADER="grub-efi"
  else
    BOOTLOADER="grub-bios"
  fi
else
  echo "❌ No supported bootloader found (systemd-boot or GRUB)."
  exit 1
fi

echo "🧭 Bootloader detected: $BOOTLOADER"

# ========================
# 🧰 Bootloader Setup
# ========================

if [[ "$BOOTLOADER" == "systemd-boot" ]]; then
  ENTRY_FILE="/boot/loader/entries/arch-${KERNEL}.conf"
  echo "📝 Creating systemd-boot entry: $ENTRY_FILE"

  sudo tee "$ENTRY_FILE" > /dev/null <<EOF
title   $KERNEL_DISPLAY
linux   /vmlinuz-${KERNEL}
initrd  /initramfs-${KERNEL}.img
options root=UUID=${ROOT_UUID} rw
EOF

  echo "⚙️  Setting default to: arch-${KERNEL}.conf"
  sudo sed -i '/^default/d' /boot/loader/loader.conf 2>/dev/null || true
  echo "default arch-${KERNEL}.conf" | sudo tee -a /boot/loader/loader.conf > /dev/null

  echo "🔄 Updating systemd-boot..."
  sudo bootctl update

elif [[ "$BOOTLOADER" == "grub-efi" || "$BOOTLOADER" == "grub-bios" ]]; then
  echo "🔄 Updating GRUB config..."
  sudo grub-mkconfig -o /boot/grub/grub.cfg
fi

# ========================
# ✅ Done
# ========================
echo "✅ Kernel '$KERNEL' installed and bootloader updated."

read -rp "🔁 Reboot now to use the new kernel? [y/N]: " confirm
if [[ "$confirm" =~ ^[Yy]$ ]]; then
  reboot
fi
