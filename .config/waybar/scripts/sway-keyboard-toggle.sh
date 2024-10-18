#!/bin/sh

# Toggle between 'us' and 'fr' keyboard layouts
if [ -f /tmp/keyboard_layout_us ]; then
    swaymsg input "*" xkb_layout fr
    rm /tmp/keyboard_layout_us
else
    swaymsg input "*" xkb_layout us
    touch /tmp/keyboard_layout_us
fi
