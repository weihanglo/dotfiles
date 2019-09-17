#!/usr/bin/env bash

#--------------------------------------#
#  .bashrc for GNU bash, version 5.0   #
#            by Weihang Lo             #
#              Sep. 2019               #
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
alias nvi='nvim --noplugin'

#---------------------------------------
# Environment variables and configs
#---------------------------------------
# LESS pager
export LESS="isFMRX"

# Aditional PATHs
export PATH="$HOME/.local/bin:$PATH"

# Bookmark manager '.bm.bash'
export BOOKMARKPATH="$HOME/.bookmarks"
[ -f $HOME/.bm.sh ] && . $HOME/.bm.sh

# EDITOR and VISUAL
export VISUAL=nvim EDITOR=nvim

# History setting ----------------------
export HISTSIZE=
export HISTCONTROL=ignoreboth
export PROMPT_COMMAND='history -a'

# Bash completion ----------------------
if [[ $(uname) == "Darwin" ]]; then
    export BASH_COMPLETION_COMPAT_DIR="$(brew --prefix)/etc/bash_completion.d"
    [[ -f "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]] && \
    . "$(brew --prefix)/etc/profile.d/bash_completion.sh"
else
    [[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] && \
    . /usr/share/bash-completion/bash_completion
fi

# RUST ---------------------------------
source "$HOME/.cargo/env"
export RUST_SRC_PATH="$(rustc --print sysroot)/lib/rustlib/src/rust/src"

# Ruby GEM_PATH ------------------------
export GEM_HOME="$HOME/.gem"
export PATH="$GEM_HOME/bin:$PATH"

# Android ANDROID_HOME -----------------
#export ANDROID_HOME="$HOME/Library/Android/sdk"
#export PATH="$ANDROID_HOME/tools/bin:$PATH"
#export PATH="$ANDROID_HOME/platform-tools:$PATH"
#alias emulator="$ANDROID_HOME/tools/emulator"

## Golang environment ------------------
export GOPATH="$HOME/.go"
export PATH="$GOPATH/bin:$PATH"

# Node.js environment configuration ----
# NVM PATH and lazy loading
export NVM_DIR="$HOME/.nvm"

__lazy_nvm() { # (macOS only)
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
    default=`cat $default_alias`
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

# Python3 configurations ---------------
# pyenv
pyenv() {
    unset -f pyenv
    source <(pyenv init -)
    pyenv $@
}

#---------------------------------------
# Enhanced prompt
#---------------------------------------

# Just launch the starship!!! (https://starship.rs/)
eval "$(starship init bash)"

#-------------------
# Miscellaneous
#-------------------

# FZF default configs
export FZF_DEFAULT_COMMAND='rg --files'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# macOS local
if [[ $(uname) == "Darwin" ]]; then
    # alias ls='ls -G'
    export LANG=en_US.UTF-8
    export LC_ALL=en_US.UTF-8
fi

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
