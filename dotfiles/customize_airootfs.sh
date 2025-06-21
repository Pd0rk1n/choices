#!/usr/bin/env bash
set -e

# Install Dracula GTK theme
echo "Installing Dracula GTK theme..."
git clone https://github.com/dracula/gtk.git /tmp/dracula-gtk
mkdir -p /usr/share/themes/Dracula
cp -r /tmp/dracula-gtk/* /usr/share/themes/Dracula
rm -rf /tmp/dracula-gtk

# Set Dracula as default GTK theme for new users
echo "Setting Dracula GTK theme as default for new users..."
mkdir -p /etc/skel/.config/gtk-3.0
cat <<EOF > /etc/skel/.config/gtk-3.0/settings.ini
[Settings]
gtk-theme-name=Dracula
EOF

