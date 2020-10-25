#!/usr/bin/env bash

#--------------------------------------#
#  .bashrc for GNU bash, version 5.0   #
#            by Weihang Lo             #
#              Oct. 2020               #
#--------------------------------------#

# Source global definitions
[[ -f /etc/bashrc ]] && . /etc/bashrc

#---------------------------------------
# User specific aliases and functions
#---------------------------------------
alias ..='cd ..'
alias ...='cd ../..'
alias ls='exa'
alias ll='exa -lhgF --git'

alias ports='lsof -PiTCP -sTCP:LISTEN'     # add sudo if needed
alias tree='exa -TF --group-directories-first'
alias cat='bat'

alias ipy='ipython3'

#---------------------------------------
# Environment variables and configs
#---------------------------------------
# LESS pager
export LESS="isFMRX"

# Aditional PATHs
export PATH="$HOME/.local/bin:$PATH"

# EDITOR and VISUAL
export VISUAL=nvim EDITOR=nvim

# History setting ----------------------
export HISTSIZE=
export HISTCONTROL="erasedups:ignoreboth"
export HISTIGNORE="&:[ ]*:exit:ls:bg:fg:history"
export PROMPT_COMMAND='history -a'

# Bash completion ----------------------
if [[ -n "$PS1" ]]; then
    if [[ $(uname) == "Darwin" ]]; then
        export BASH_COMPLETION_COMPAT_DIR="$(brew --prefix)/etc/bash_completion.d"
        [[ -f "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]] && \
        . "$(brew --prefix)/etc/profile.d/bash_completion.sh"
    else
        [[ -f /usr/share/bash-completion/bash_completion ]] && \
        . /usr/share/bash-completion/bash_completion
    fi
fi

# Ruby GEM_PATH ------------------------
export GEM_HOME="$HOME/.gem"
export PATH="$GEM_HOME/bin:$PATH"

## Golang environment ------------------
export GOPATH="$HOME/.go"
export PATH="$GOPATH/bin:$PATH"

# Node.js environment configuration ----
# NVM PATH and lazy loading
export NVM_DIR="$HOME/.nvm"

__lazy_nvm() {
    if [[ $(uname) == "Darwin" ]]; then
        local _NVM_SH="$(brew --prefix nvm)/nvm.sh"
    else
        local _NVM_SH="$HOME/.nvm/nvm.sh"
    fi
    [ -s $_NVM_SH ] && . $_NVM_SH
}

# load executable in alias=default
__find_node_globals() {
    default_alias="$NVM_DIR/alias/default"
    if [ ! -s $default_alias ]; then
        return
    fi
    default=`\cat $default_alias`
    if [ "$default" = 'system' ]; then
        return
    fi
    node_globals=(`find \
        $NVM_DIR/versions/node/$default/bin -maxdepth 1 -type l | \
        xargs -n 1 basename`)
    node_globals+=("node")
    node_globals+=("nvm")

    for cmd in "${node_globals[@]}"; do
        eval "${cmd}(){ unset -f ${node_globals[@]}; __lazy_nvm; ${cmd} \$@; }"
    done
    unset cmd
}

__find_node_globals # Must load after bash completions.

# Python -------------------------------
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
export PIPENV_PYTHON="$PYENV_ROOT/shims/python"
source <(pyenv init -)

# RUST ---------------------------------
source "$HOME/.cargo/env"

#---------------------------------------
# Enhanced prompt
#---------------------------------------

# Just launch the starship!!! (https://starship.rs/)
eval "$(starship init bash)"

#---------------------------------------
# Miscellaneous
#---------------------------------------

# FZF default configs
export FZF_DEFAULT_COMMAND='rg --files'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
