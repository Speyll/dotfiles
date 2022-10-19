#!/bin/sh
if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?* ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

# Xresources
if [ -f $HOME/.Xresources ]; then
    xrdb -merge $HOME/.Xresources
fi

# Defaults
xbacklight -set 60 &

# Color Temperature
sctd &

# Set Wallpaper
hsetroot -cover "$HOME/pictures/wall.webp" &

# Cursor
xsetroot -cursor_name left_ptr &

# Bar
$HOME/.config/lemonbar/lemon.sh &

# Picom
$HOME/.config/picom/lpicom.sh &

# sxhkd
pkill sxhkd
sxhkd -c $HOME/.config/sxhkd/sxhkdrc -m 1 &

# Graphical Interface
exec bspwm
