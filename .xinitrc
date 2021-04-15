#!/bin/sh
if [ -d /etc/X11/xinit/xinitrc.d ] ; then
 for f in /etc/X11/xinit/xinitrc.d/?* ; do
  [ -x "$f" ] && . "$f"
 done
 unset f
fi

# rice
$HOME/.config/autostart/rice &

# general settings
xrdb -merge $HOME/.Xresources &

# wm settings
exec 2bwm
