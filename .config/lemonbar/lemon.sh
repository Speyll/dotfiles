#!/bin/sh
pkill lemonbar | pkill sleep
while pgrep -u $UID -x lemonbar >/dev/null; do sleep 1; done

# Colors
background="#002b36"
forground="#93a1a1"

"$HOME"/.config/lemonbar/bar | lemonbar -f "kakwafont:size=12" -f "Siji:size=10" -F $forground -B $background -g x20 -n "lemon" &