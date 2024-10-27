# ~/.profile: executed by the command interpreter for login shells.
# This file is not read by bash(1), if ~/.bash_profile or ~/.bash_login
# exists.
# see /usr/share/doc/bash/examples/startup-files for examples.
# the files are located in the bash-doc package.

# the default umask is set in /etc/profile; for setting the umask
# for ssh logins, install and configure the libpam-umask package.
#umask 022

# Enable bashrc if running bash
if [ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ]; then
    . "$HOME/.bashrc"
fi

# Set PATH so it includes user's private bin if it exists
if [ -d "$HOME/bin" ] ; then
    PATH="$HOME/bin:$PATH"
fi

# Add $HOME/.local/bin to the $PATH
if [ -d "$HOME/.local/bin" ]; then
    PATH="$HOME/.local/bin:$PATH"
fi

# Enable colors in your shell
export CLICOLOR=1
export TERM=xterm-256color
export GREP_OPTIONS="--color=always"

# Default programs variables
export EDITOR="nvim"
export FILE="nnn"
export PAGER="less"

# Setting default XDG dirs
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_RUNTIME_DIR="/run/user/$(id -u)"

# Cleaning up $HOME dir
export NOTMUCH_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/notmuch-config"
export GTK2_RC_FILES="${XDG_CONFIG_HOME:-$HOME/.config}/gtk-2.0/gtkrc-2.0"
export LESSHISTFILE="-"
export WGETRC="${XDG_CONFIG_HOME:-$HOME/.config}/wget/wgetrc"
export TMUX_TMPDIR="$XDG_RUNTIME_DIR"
export WINEPREFIX="$1;2C{XDG_DATA_HOME:-$HOME/.local/share}/wineprefixes/default"
export KODI_DATA="${XDG_DATA_HOME:-$HOME/.local/share}/kodi"
export PASSWORD_STORE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/password-store"
export ANDROID_SDK_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/android"
export CARGO_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/cargo"
export GOPATH="${XDG_DATA_HOME:-$HOME/.local/share}/go"
export ANSIBLE_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/ansible/ansible.cfg"
export WEECHAT_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/weechat"
export MBSYNCRC="${XDG_CONFIG_HOME:-$HOME/.config}/mbsync/config"
export ELECTRUMDIR="${XDG_DATA_HOME:-$HOME/.local/share}/electrum"

# Disable GTK smooth scrolling
export GTK_OVERLAY_SCROLLING=0

# Password management
export PASSWORD_STORE_DIR="${XDG_DATA_HOME}/password-store"
export SUDO_ASKPASS="$HOME/.local/bin/dmenupass"

# Fix for Java applications in dwm & wayland
export _JAVA_AWT_WM_NONREPARENTING=1

# Configuration for nnn, remove if you don't use it.
export NNN_OPTS="dH"

# Enable if your gpu lack support for Alacritty
#export LIBGL_ALWAYS_SOFTWARE=1 alacritty

# Autologin on tty1
#if [ -z "$DISPLAY" ] && [ "$(fgconsole)" -eq 1 ]; then
    #start-labwc
#fi
