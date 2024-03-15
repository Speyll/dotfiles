#!/bin/sh

# Kill existing Pipewire processes
pkill -x pipewire
pkill -x wireplumber
pkill -x pipewire-pulse

# Start a fresh Pipewire session
dbus-run-session pipewire &
sleep 1
wireplumber &
pipewire-pulse &