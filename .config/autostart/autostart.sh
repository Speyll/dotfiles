#!/bin/sh

# Start Pipewire
$HOME/.config/autostart/start-pipewire.sh &

# Set wallpaper with swaybg
swaybg --mode fill -i "$HOME/pictures/wall.jpg" &

# Set cursor
gsettings set org.gnome.desktop.interface cursor-theme Breeze_Snow &
seat seat0 xcursor_theme Breeze_Snow &

# Kill and start Mako
pkill -x mako
mako &

# Kill and start Night light
pkill -x wlsunset
wlsunset -l 36.7 -L 3.08 &
