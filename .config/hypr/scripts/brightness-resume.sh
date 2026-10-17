#!/usr/bin/env bash

# Restore the saved laptop/internal display brightness
brightnessctl -r

# Allow external monitors to wake after DPMS
sleep 0.8

# Restore configured external monitor brightness levels
ddcutil --display 1 setvcp 10 50 >/dev/null 2>&1
ddcutil --display 2 setvcp 10 55 >/dev/null 2>&1
