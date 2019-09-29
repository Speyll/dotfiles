#!/bin/sh
if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?* ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

# Wm settings
xrdb -merge ~/.Xresources &
sxhkd -c ~/.config/bspwm/sxhkdrc -m 1 &
exec bspwm
