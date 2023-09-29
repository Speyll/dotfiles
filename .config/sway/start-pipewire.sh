#!/bin/sh
# Check if Pipewire is running
if ! pgrep -x "pipewire" > /dev/null; then
  echo "Pipewire is not running. Starting..."
  dbus-run-session pipewire &
  sleep 1
  wireplumber &
  pipewire-pulse &
else
  echo "Pipewire is already running."
fi
