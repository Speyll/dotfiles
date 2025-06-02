# ~/.profile: executed by login shells

# Source .bashrc if available
[ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"

# Add directories to PATH without duplicates
path_prepend() {
    [ -d "$1" ] && [[ ":$PATH:" != *":$1:"* ]] && PATH="$1:$PATH"
}

# User binaries and Nix paths (priority order)
path_prepend "$HOME/.nix-profile/bin"      # Nix user packages
path_prepend "$HOME/.nix-profile/sbin"     # Nix user system utilities
path_prepend "/nix/var/nix/profiles/default/bin"  # Default Nix profile
path_prepend "$HOME/bin"                   # Personal scripts
path_prepend "$HOME/.local/bin"            # Local user binaries
export PATH

# Core terminal environment
export TERMINAL="alacritty"
export TERM="xterm-256color"
export CLICOLOR=1
export EDITOR="nvim"
export PAGER="less"
export FILE="nnn"

# XDG Base Directory Specification
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_RUNTIME_DIR="/run/user/$(id -u)"

# XDG-compliant application settings
export NOTMUCH_CONFIG="$XDG_CONFIG_HOME/notmuch-config"
export GTK2_RC_FILES="$XDG_CONFIG_HOME/gtk-2.0/gtkrc-2.0"
export WGETRC="$XDG_CONFIG_HOME/wget/wgetrc"
export WINEPREFIX="$XDG_DATA_HOME/wineprefixes/default"
export KODI_DATA="$XDG_DATA_HOME/kodi"
export PASSWORD_STORE_DIR="$XDG_DATA_HOME/password-store"
export ANDROID_SDK_HOME="$XDG_CONFIG_HOME/android"
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export GOPATH="$XDG_DATA_HOME/go"
export ANSIBLE_CONFIG="$XDG_CONFIG_HOME/ansible/ansible.cfg"
export WEECHAT_HOME="$XDG_CONFIG_HOME/weechat"
export MBSYNCRC="$XDG_CONFIG_HOME/mbsync/config"
export ELECTRUMDIR="$XDG_DATA_HOME/electrum"
export NPM_CONFIG_USERCONFIG="$XDG_CONFIG_HOME/npm/npmrc"

# Application-specific settings
export LESSHISTFILE="-"                     # Disable Less history
export GTK_OVERLAY_SCROLLING=0             # Disable smooth scrolling
export _JAVA_AWT_WM_NONREPARENTING=1       # Fix Java GUI apps
export TMUX_TMPDIR="$XDG_RUNTIME_DIR"

# Nix environment configuration
export NIX_PATH="nixpkgs=$HOME/.nix-defexpr/channels/nixpkgs"
export NIX_SSL_CERT_FILE="/etc/ssl/certs/ca-certificates.crt"

# FZF theming (handled in .bashrc for key bindings)
export FZF_DEFAULT_OPTS="--color=fg:7,bg:-1,hl:1 --color=fg+:15,bg+:8,hl+:9 --color=info:14,prompt:13,pointer:12,marker:10,spinner:11"

# NNN configuration (if installed)
command -v nnn >/dev/null && export NNN_OPTS="dH"

export GTK_USE_PORTAL=1
