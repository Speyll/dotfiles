# ~/.profile: executed by login shells

# 1. Source .bashrc if available (POSIX compliant check)
[ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"

# 2. Pure POSIX path_prepend (No bashisms, zero subshells, lightning fast)
path_prepend() {
    [ -d "$1" ] || return 0
    case ":$PATH:" in
        *":$1:"*) ;;
        *) PATH="$1:$PATH" ;;
    esac
}

# User binaries and Nix paths (priority order)
path_prepend "$HOME/.nix-profile/bin"
path_prepend "$HOME/.nix-profile/sbin"
path_prepend "/nix/var/nix/profiles/default/bin"
path_prepend "$HOME/bin"
path_prepend "$HOME/.local/bin"
export PATH

# Environment hygiene: erase the function from memory so it doesn't pollute your shell
unset -f path_prepend

# 3. Core & XDG Base Directory Specification
export TERMINAL="foot"
export CLICOLOR=1
export EDITOR="nvim"
export PAGER="less"
export FILE="nnn"

export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_CACHE_HOME="$HOME/.cache"
# Note: XDG_RUNTIME_DIR is deliberately omitted. Let systemd set it safely.

# 4. XDG-compliant & Application settings (Grouped for sequential parsing)
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

export LESSHISTFILE="-"
export GTK_OVERLAY_SCROLLING=0
export _JAVA_AWT_WM_NONREPARENTING=1
export MESA_SHADER_CACHE_MAX_SIZE="100G"

# Dynamically export TMUX_TMPDIR only if systemd has already provided XDG_RUNTIME_DIR
[ -n "$XDG_RUNTIME_DIR" ] && export TMUX_TMPDIR="$XDG_RUNTIME_DIR"

# 5. Nix & App Environments
export NIX_PATH="nixpkgs=$HOME/.nix-defexpr/channels/nixpkgs"
export NIX_SSL_CERT_FILE="/etc/ssl/certs/ca-certificates.crt"
export NNN_OPTS="dH"
export FZF_DEFAULT_OPTS="--color=fg:7,bg:-1,hl:1 --color=fg+:15,bg+:8,hl+:9 --color=info:14,prompt:13,pointer:12,marker:10,spinner:11"
