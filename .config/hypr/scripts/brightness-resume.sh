#!/usr/bin/env bash

# 1. Restore laptop/internal display
brightnessctl -r

# 2. Brief pause to allow external monitor microcontrollers to wake from DPMS
sleep 0.8

# 3. Restore external displays by Display Index (stable across reboots)
ddcutil --display 1 setvcp 10 50 >/dev/null 2>&1
ddcutil --display 2 setvcp 10 55 >/dev/null 2>&1
