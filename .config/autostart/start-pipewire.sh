#!/bin/sh

# Function to kill process by name
kill_process() {
    local pid=$(pgrep "$1")
    if [ -n "$pid" ]; then
        kill "$pid"
    fi
}

# Kill existing Pipewire processes
kill_process pipewire
kill_process wireplumber
kill_process pipewire-pulse

# Start a fresh Pipewire session
echo "Starting Pipewire..."
dbus-run-session pipewire &
sleep 1
wireplumber &
pipewire-pulse &
