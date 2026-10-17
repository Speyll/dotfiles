#!/usr/bin/env bash

# Dim laptop/internal display, if present
brightnessctl -s set 10%

# Dim both external monitors
ddcutil --display 1 setvcp 10 5 >/dev/null 2>&1
ddcutil --display 2 setvcp 10 5 >/dev/null 2>&1
