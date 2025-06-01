# ~/.bashrc: executed by bash(1) for non-login shells.

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# History settings
export HISTCONTROL=ignoredups:erasedups
export HISTSIZE=1000
export HISTFILESIZE=2000
shopt -s histappend

# Write and reload history after each command to ensure deduplication
export PROMPT_COMMAND='history -a; history -n cleanup-history'

# Enable programmable completion
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

# Check window size after each command
shopt -s checkwinsize

# Color prompt setup
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    PROMPT_COMMAND='PS1="\[\e]0;\u@\h: \w\a\][\[\e[32m\]\A\[\e[0m\]][\[\e[34m\]\h\[\e[0m\]][\$(branch=\$(git branch --show-current 2>/dev/null); if [ -n \"\$branch\" ]; then echo -e \"\[\e[35m\]\$branch\[\e[0m\] \"; fi)\]\[\e[33m\]\w\[\e[0m\]]\$ "'
else
    PS1='[\A][\h][\w]\$ '
fi

# Set terminal title for supported terminals
case "$TERM" in
    xterm*|rxvt*|foot*|alacritty*)
        PS1="\[\e]0;\u@\h: \w\a\]$PS1"
        ;;
esac

# Load aliases
[[ -f ~/.config/aliasrc ]] && . ~/.config/aliasrc

# Proper FZF integration
if [[ -f /usr/share/doc/fzf/examples/key-bindings.bash ]]; then
    source /usr/share/doc/fzf/examples/key-bindings.bash
elif [[ -f ~/.fzf.bash ]]; then
    source ~/.fzf.bash
elif [[ -f /usr/share/fzf/key-bindings.bash ]]; then
    source /usr/share/fzf/key-bindings.bash
fi

# Keep bash history clean
cleanup-history() {
    local histfile="$HOME/.bash_history"
    [[ -r "$histfile" ]] || return
    awk '
    {
        cleaned = $0
        gsub(/[[:space:]]*$/, "", cleaned)
        if (cleaned != "") {
            last[cleaned] = NR
            line[NR] = cleaned
        }
    }
    END {
        for (i = 1; i <= NR; i++) {
            if (i in line && last[line[i]] == i) {
                print line[i]
            }
        }
    }
    ' "$histfile" > "${histfile}.tmp"
    if [[ -s "${histfile}.tmp" ]]; then
        command mv -f "${histfile}.tmp" "$histfile" >/dev/null 2>&1
    else
        rm -f "${histfile}.tmp" >/dev/null 2>&1
    fi
    history -c
    history -r
}

# Enhanced history search (CTRL-R)
__fzf_history__() {
    history -a
    history -c
    history -r
    local line
    line=$(history | fzf --height 100% --tac --tiebreak=index --no-sort --exact \
            --bind 'ctrl-d:page-down,ctrl-u:page-up' | sed 's/^ *[0-9]* *//')
    if [[ -n "$line" ]]; then
        READLINE_LINE=$line
        READLINE_POINT=${#line}
    fi
}

# Bind CTRL-R to the history search function in interactive shells
if [[ $- == *i* ]]; then
    bind -x '"\C-r": __fzf_history__'
fi

# FZF preview with bat if available, otherwise cat
if command -v bat >/dev/null 2>&1; then
    export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :500 {}'"
else
    export FZF_CTRL_T_OPTS="--preview 'cat {}'"
fi

# Run command without logging to history
nhist() {
    HISTFILE=/dev/null
    bash -ic "$*"
    history -d $(history 1)
}
