#!/usr/bin/env sh

# Define the variable that holds the last result
LAST=""

# Don't stop until the user hits escape or clicks off of fuzzel
while true; do
	# Add a space on the first run
	[ -z "$LAST" ] && SPACE=" "
	# Get user input
	NEXT="$(fuzzel -l 0 --dmenu -p "${LAST}${SPACE}")"
	# Quit if empty
	[ -z "$NEXT" ] && exit 1
	# Copy and exit if y is entered
	[ "$NEXT" = "y" ] && wl-copy "$LAST" && exit 0
	# Pipe the expression into bc and strip off trailing zeroes
	LAST="$(echo "$LAST$NEXT" | bc -l | sed '/\./ s/\.\{0,1\}0\{1,\}$//')"
done
