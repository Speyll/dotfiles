#!/bin/sh

# Environment Setup
dbus-update-activation-environment --all &

# Polkit Agent
/usr/libexec/polkit-gnome-authentication-agent-1 &

# Output and Display Configuration
wlr-randr --output HDMI-A-1 --mode 1920x1080@60.000000 --adaptive-sync enabled &

# Kill Existing Processes
pkill -x flavours
pkill -x pipewire
pkill -x wireplumber
pkill -x pipewire-pulse
pkill -x mpvpaper
pkill -x swaybg
pkill -x fnott
pkill -x wlsunset
pkill -x waybar
pkill -x cliphist

# Start PipeWire and Services
dbus-run-session pipewire &
sleep 1
wireplumber &
pipewire-pulse &

# Set Wallpaper and Generate Flavours Theme
wallpaper_path=$(find $HOME/pictures/walls/*.jpg -type f | shuf -n1)
swaybg -i "$wallpaper_path" -m fill &

# Generate and apply the Flavours theme based on the wallpaper
#flavours generate dark "$wallpaper_path"
#flavours apply generated
flavours apply gruvbox-dark-medium
gsettings set org.gnome.desktop.interface color-scheme prefer-dark

# Start Waybar
waybar -c $HOME/.config/waybar/stacking-config -s $HOME/.config/waybar/style.css &

# Cursor Theme
gsettings set org.gnome.desktop.interface cursor-theme Breeze_Snow &
seat seat0 xcursor_theme Breeze_Snow &

# Start Additional Services
fnott &                  # Notifications
wlsunset -l 36.7 -L 3.08 &  # Night light
wl-paste --watch cliphist store -max-items 100 &  # Clipboard manager

# Start XDG Desktop Portal Services
/usr/libexec/xdg-desktop-portal &
/usr/libexec/xdg-desktop-portal-gtk &
/usr/libexec/xdg-desktop-portal-wlr &

