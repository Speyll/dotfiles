#!/bin/sh

wal -c | wal -i $HOME/Pictures/Walls &
$HOME/.config/sxhkd/launch.sh &
$HOME/.config/picom/launch.sh &
$HOME/.config/polybar/launch.sh &
xsetroot -cursor_name left_ptr &
