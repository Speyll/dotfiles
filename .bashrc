# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# History settings
export HISTCONTROL=ignorespace:ignoredups:erasedups
export PROMPT_COMMAND='cleanup-history; history -a; history -n'
export HISTSIZE=1000
export HISTFILESIZE=2000
shopt -s histappend

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

# fzf history
bind '"\C-r": "\C-x1\e^\er"'
bind -x '"\C-x1": __fzf_history';

__fzf_history ()
{
    # Capture the selected command from history using fzf
    local selected_cmd
    selected_cmd=$(history | fzf --tac --tiebreak=index | perl -ne 'm/^\s*([0-9]+)\s*(.*)/ and print "$2"')

    # Check if the selected command is different from the last history entry and the last executed command
    if [[ -n $selected_cmd && $selected_cmd != "$(history 1 | sed 's/^[ ]*[0-9]*[ ]*//')" ]]; then
        __ehc "$selected_cmd"
    fi
}

__ehc()
{
    if [[ -n $1 ]]; then
        bind '"\er": redraw-current-line'
        READLINE_LINE=${READLINE_LINE:+${READLINE_LINE:0:READLINE_POINT}}${1}${READLINE_LINE:+${READLINE_LINE:READLINE_POINT}}
        READLINE_POINT=$(( READLINE_POINT + ${#1} ))
    else
        bind '"\er":'
    fi
}

# `tm` will allow you to select your tmux session via fzf.
tm() {
  [[ -n "$TMUX" ]] && change="switch-client" || change="attach-session"
  if [ $1 ]; then
    tmux $change -t "$1" 2>/dev/null || (tmux new-session -d -s $1 && tmux $change -t "$1"); return
  fi
  session=$(tmux list-sessions -F "#{session_name}" 2>/dev/null | fzf --exit-0) &&  tmux $change -t "$session" || echo "No sessions found."
}
