#!/bin/sh

# Define the repository URL and the fonts directory
REPO_URL="https://github.com/Speyll/fonts.git"
FONT_DIR="$HOME/.local/share/fonts/fonts_repo" # Temporary directory for cloning

# Clone or update the fonts repository
if [ -d "$FONT_DIR" ]; then
    # If the directory exists, pull the latest changes
    cd "$FONT_DIR"
    git pull
else
    # Clone the repository if it doesn't exist
    git clone "$REPO_URL" "$FONT_DIR"
fi

# Move fonts to the main fonts directory
mv "$FONT_DIR/"* "$HOME/.local/share/fonts/"
# Optionally remove the temporary directory
rm -rf "$FONT_DIR"

# Update font cache
fc-cache -f -v

echo "Fonts installed/updated successfully!"
