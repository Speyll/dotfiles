#!/bin/sh

# Toggle between 'us' and 'fr' keyboard layouts
swaymsg input '*' xkb_switch_layout next
