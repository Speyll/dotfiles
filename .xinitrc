#!/bin/sh
if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?* ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

# rice
$HOME/.config/rice/rice.sh &

# general settings
xrdb -merge $HOME/.Xresources &

# wm settings
#sxhkd -c $HOME/.config/bspwm/sxhkdrc -m 1 &
#exec bspwm
exec sowm