# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# History settings
HISTCONTROL=ignorespace:ignoredups:erasedups
PROMPT_COMMAND='history -a; history -n;'
shopt -s histappend
HISTSIZE=1000
HISTFILESIZE=2000

# Enable programmable completion features
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Check window size after each command
shopt -s checkwinsize

# Make less more friendly for non-text input files, see lesspipe
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# Color settings
## Determine if the terminal supports color
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    color_prompt=yes
else
    color_prompt=no
fi

## Set the prompt based on color support
if [ "$color_prompt" = yes ]; then
    PS1='[\[\e[32m\]\A\[\e[0m\]][\[\e[34m\]\h\[\e[0m\]][\[\e[33m\]\w\[\e[0m\]]\$ '
else
    PS1='[\A][\h\][\w]\$ '
fi

## If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*|foot*)
    PS1='[\[\e[32m\]\A\[\e[0m\]][\[\e[34m\]\h\[\e[0m\]][\[\e[33m\]\w\[\e[0m\]]\$ '
    ;;
*)
    ;;
esac

# Alias definition
if [ -f ~/.config/aliasrc ]; then
    . ~/.config/aliasrc
fi

# Enable bash completion
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Function to search command history with fzf
fzf_history() {
  local selected_command
  selected_command=$(history | fzf | awk '{$1=""; print substr($0,2)}')
  if [[ -n $selected_command ]]; then
    eval "$selected_command"
  fi
}
