#!/bin/sh
# Kill existing Pipewire processes
pkill -x pipewire
pkill -x wireplumber
pkill -x pipewire-pulse

# Start a fresh Pipewire session
echo "Starting Pipewire..."
dbus-run-session pipewire &
sleep 1
wireplumber &
pipewire-pulse &

echo "Pipewire is ready to rock!"
