#!/usr/bin/env bash

# 1. Dim laptop/internal display (if present)
brightnessctl -s set 10%

# 2. Dim all connected external DDC/CI monitors sequentially
# Running 'ddcutil setvcp 10 5' without --bus targets all detected DDC displays safely
ddcutil setvcp 10 5 >/dev/null 2>&1
