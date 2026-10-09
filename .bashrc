# ~/.bashrc: executed by bash(1) for non-login shells.

# 1. Fast-fail for non-interactive shells
[[ $- == *i* ]] || return

# HISTORY SETTINGS
export HISTCONTROL=ignoreboth:erasedups
export HISTIGNORE="ls:cd:pwd:exit:clear:history*"
export HISTSIZE=5000
export HISTFILESIZE=5000
shopt -s histappend checkwinsize

# Natively deduplicate and sync history across all footclients instantly.
# Appends new commands, clears memory, and reloads from disk.
# This forces `erasedups` to apply globally without any slow awk scripts or .tmp files.
_sync_history() {
    history -a
    history -c
    history -r
}

# PROMPT & GIT
_git_branch() {
    local branch
    branch=$(git branch --show-current 2>/dev/null)
    [[ -n "$branch" ]] && printf '\[\e[35m\]%s\[\e[0m\] ' "$branch"
}

# Evaluate terminal color capability ONCE at startup, not every prompt
if [[ -x /usr/bin/tput ]] && tput setaf 1 >/dev/null 2>&1; then
    _set_prompt() {
        _sync_history
        PS1="\[\e]0;\u@\h: \w\a\][\[\e[32m\]\A\[\e[0m\]][\[\e[34m\]\h\[\e[0m\]][$(_git_branch)\[\e[33m\]\w\[\e[0m\]]\$ "
    }
    PROMPT_COMMAND="_set_prompt"
else
    PROMPT_COMMAND="_sync_history"
    PS1='[\A][\h][\w]\$ '
fi

# ALIASES & COMPLETION
[[ -f ~/.config/aliasrc ]] && source ~/.config/aliasrc

if ! shopt -oq posix; then
    if [[ -r /usr/share/bash-completion/bash_completion ]]; then
        source /usr/share/bash-completion/bash_completion
    elif [[ -r /etc/bash_completion ]]; then
        source /etc/bash_completion
    fi
fi

# FZF INTEGRATION
for _fzf_script in \
    /usr/share/doc/fzf/examples/key-bindings.bash \
    "$HOME/.fzf.bash" \
    /usr/share/fzf/key-bindings.bash \
    /usr/share/fzf/shell/key-bindings.bash; do
    if [[ -r "$_fzf_script" ]]; then
        source "$_fzf_script"
        break
    fi
done
unset _fzf_script

# Set FZF previewer ONCE at startup
if command -v bat >/dev/null 2>&1; then
    export FZF_CTRL_T_OPTS="--preview 'bat --color=always --line-range :500 {}'"
else
    export FZF_CTRL_T_OPTS="--preview 'cat {}'"
fi

# Enhanced history search (CTRL-R)
__fzf_history__() {
    _sync_history
    local line
    line=$(HISTTIMEFORMAT= history | fzf --height 100% --tac --tiebreak=index --no-sort --exact \
            --bind 'ctrl-d:page-down,ctrl-u:page-up')

    if [[ -n "$line" ]]; then
        if [[ "$line" =~ ^[[:space:]]*[0-9]+[[:space:]]+(.*)$ ]]; then
            READLINE_LINE="${BASH_REMATCH[1]}"
            READLINE_POINT=${#READLINE_LINE}
        fi
    fi
}
bind -x '"\C-r": __fzf_history__'
