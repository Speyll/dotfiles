#!/bin/sh

# Update DBus session
dbus-update-activation-environment --all &

# Set output and adaptive sync
wlr-randr --output HDMI-A-1 --mode 1920x1080@60.000000 --adaptive-sync enabled &

# Kill existing processes to avoid duplicates
pkill -x pipewire
pkill -x wireplumber
pkill -x pipewire-pulse
pkill -x fnott
pkill -x wlsunset
pkill -x waybar
pkill -x cliphist

# Start PipeWire and related services
dbus-run-session pipewire &
sleep 1
wireplumber &
pipewire-pulse &

# Start Waybar
waybar -c $HOME/.config/waybar/stacking-config -s $HOME/.config/waybar/style.css &

# Set wallpaper with swaybg
swaybg --mode fill -i "$HOME/pictures/wall.jpg" &

# Set cursor theme
gsettings set org.gnome.desktop.interface cursor-theme Breeze_Snow &
seat seat0 xcursor_theme Breeze_Snow &

# Start notifications
fnott &

# Start Night light
wlsunset -l 36.7 -L 3.08 &

# Start clipboard manager
wl-paste --watch cliphist store -max-items 100 &

# Start xdg-desktop-portal services
/usr/libexec/xdg-desktop-portal &
/usr/libexec/xdg-desktop-portal-gtk &
/usr/libexec/xdg-desktop-portal-wlr &
