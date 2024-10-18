#!/bin/sh

# Environment Setup
dbus-update-activation-environment --all &

# Polkit Agent
/usr/libexec/polkit-gnome-authentication-agent-1 &

# Output and Display Configuration
wlr-randr --output HDMI-A-1 --mode 1920x1080@60.000000 --adaptive-sync enabled &

# Kill Existing Processes
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

# Start Waybar
waybar -c $HOME/.config/waybar/stacking-config -s $HOME/.config/waybar/style.css &
# waybar -c $HOME/.config/waybar/tiling-config -s $HOME/.config/waybar/style.css &

# Set Wallpaper
swaybg -i $(find $HOME/pictures/walls/*.jpg -type f | shuf -n1) -m fill &
# swaybg --mode fill -i "$HOME/pictures/walls/wall.jpg" &
# mpvpaper -vsp -o "no-audio pause=no --loop --ytdl-format='bestvideo[height<=1080]+bestaudio/best'" '*' "$HOME/pictures/walls/wall.mp4" &
# mpvpaper -vsp -o "no-audio pause=no --loop --ytdl-format='bestvideo[height<=1080]+bestaudio/best'" '*' $(find $HOME/pictures/walls/*.mp4 -type f | shuf -n1) &

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
