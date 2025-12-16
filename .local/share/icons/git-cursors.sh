#!/bin/sh

# Define the repository URL and the fonts directory
REPO_URL="https://github.com/Speyll/cursors.git"
CUR_DIR="$HOME/.local/share/fonts/cursors_repo" # Temporary directory for cloning

# Clone or update the cursors repository
if [ -d "$CUR_DIR" ]; then
    # If the directory exists, pull the latest changes
    cd "$CUR_DIR"
    git pull
else
    # Clone the repository if it doesn't exist
    git clone "$REPO_URL" "$CUR_DIR"
fi

# Move cursors to the main fonts directory
mv "$CUR_DIR/"* "$HOME/.local/share/icons/"
# Optionally remove the temporary directory
rm -rf "$CUR_DIR"

echo "cursors installed/updated successfully!"
