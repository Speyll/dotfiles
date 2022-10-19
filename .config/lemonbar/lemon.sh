#!/bin/sh
pkill lemonbar | pkill sleep
while pgrep -u $UID -x lemonbar >/dev/null; do sleep 1; done

# Colors
background="#222529"
forground="#D6D6D6"

"$HOME"/.config/lemonbar/bar | lemonbar -f "sans-serif:size=12" -f "FontAwesome:size=12" -F $forground -B $background -g x24 -n "lemon" &