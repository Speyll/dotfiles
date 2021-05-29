#!/bin/sh

pkill -x polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done
polybar bspbar &