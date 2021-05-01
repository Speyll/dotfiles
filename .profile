#!/bin/sh
# .profile - Bourne Shell startup script for login shells

# Personal additional paths in ~/.local/bin:
export PATH=$PATH$(find $HOME/.local/bin/ -type d -printf ":%p")

# Make sure everything is set to exectuable
chmod +x $HOME/.local/bin/*
chmod +x $HOME/.local/bin/*/*
chmod +x $HOME/.config/autostart/*

# BLOCKSIZE=K;	export BLOCKSIZE
# Setting TERM is normally done through /etc/ttys.
# Do only override if you're sure that you'll never log in via telnet or xterm or a serial line.

# Default programs:
export TERM="st"
export EDITOR="nvim"
export FILE="nnn"
export PAGER="less"

# Rearranging some files
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
export NOTMUCH_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/notmuch-config"
export GTK2_RC_FILES="${XDG_CONFIG_HOME:-$HOME/.config}/gtk-2.0/gtkrc-2.0"
export LESSHISTFILE="-"
export WGETRC="${XDG_CONFIG_HOME:-$HOME/.config}/wget/wgetrc"
export INPUTRC="${XDG_CONFIG_HOME:-$HOME/.config}/inputrc"
export TMUX_TMPDIR="$XDG_RUNTIME_DIR"
export WINEPREFIX="${XDG_DATA_HOME:-$HOME/.local/share}/wineprefixes/default"
export KODI_DATA="${XDG_DATA_HOME:-$HOME/.local/share}/kodi"
export PASSWORD_STORE_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/password-store"
export TMUX_TMPDIR="$XDG_RUNTIME_DIR"
export ANDROID_SDK_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/android"
export CARGO_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/cargo"
export GOPATH="${XDG_DATA_HOME:-$HOME/.local/share}/go"
export ANSIBLE_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/ansible/ansible.cfg"
export HISTFILE="${XDG_DATA_HOME:-$HOME/.local/share}/history"
export WEECHAT_HOME="${XDG_CONFIG_HOME:-$HOME/.config}/weechat"
export MBSYNCRC="${XDG_CONFIG_HOME:-$HOME/.config}/mbsync/config"
export ELECTRUMDIR="${XDG_DATA_HOME:-$HOME/.local/share}/electrum"

# Other program settings:
export DICS="/usr/share/stardict/dic/"
export SUDO_ASKPASS="$HOME/.local/bin/dmenupass"
export _JAVA_AWT_WM_NONREPARENTING=1	# Fix for Java applications in dwm

# set bashrc each time sh is started for interactive use.
[ -f $HOME/.bashrc ] && . $HOME/.bashrc
#[ -f $HOME/.ashrc ] && . $HOME/.ashrc
