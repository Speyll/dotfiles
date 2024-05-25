#!/usr/bin/env sh

# Main cache file
cache_file="$HOME/.cache/todo.cache"
# Secondary temp cache file 
cache_file_2="$HOME/.cache/todo2.cache"
# Output of cache file 
cache_contents="$(cat "$cache_file")"
# Number of lines in cache file
cache_lines="$(echo "$cache_contents" | wc -l)"

# If the cache file is empty, ignore the blank line and set lines to 0
[ -s "$cache_file" ] || cache_lines=0

# Get input from the user
selection="$(echo "$cache_contents" | fuzzel --dmenu -l "$cache_lines" 2>/dev/null)"

# Exit if no selection is received
[ -z "$selection" ] && exit 1

# If the selection already exists in the cache file
if grep -q "$selection" "$cache_file"; then
	# Remove it
	grep -v "^${selection}$" "$cache_file" > "$cache_file_2"
	mv "$cache_file_2" "$cache_file"
else
	# Otherwise append it
	echo "$selection" >> "$cache_file"
fi
