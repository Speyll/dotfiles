#!/bin/sh

# Function to kill process by name
kill_process() {
    local pid=$(pgrep "$1")
    if [ -n "$pid" ]; then
        kill "$pid"
    fi
}

# Set wallpaper with swaybg
swaybg --mode fill -i "$HOME/pictures/wall.jpg" &

# Start Pipewire
"$HOME/.config/autostart/start-pipewire.sh" &

# Kill and start Mako
kill_process mako
mako &

# Kill and start Night light
kill_process wlsunset
wlsunset -l 36.7 -L 3.08 &
