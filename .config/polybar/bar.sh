#!/bin/sh
# Kill
pkill polybar | pkill sleep
pkill -x polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done

# Launch
polybar bspbar &