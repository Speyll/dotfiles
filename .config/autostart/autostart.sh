#!/bin/sh

# Start Pipewire
$HOME/.config/autostart/start-pipewire.sh &

# Set wallpaper with swaybg
swaybg --mode fill -i "$HOME/pictures/wall.jpg" &

# Kill and start Mako
pkill -x mako
mako &

# Kill and start Night light
pkill -x wlsunset
wlsunset -l 36.7 -L 3.08 &
