#!/bin/sh
if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?* ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

# general settings
xrdb -merge ~/.Xresources &

# bspwm settings
sxhkd -c ~/.config/bspwm/sxhkdrc -m 1 &
exec bspwm
