#!/bin/bash

#--------------------------------------#
#  .bashrc for GNU bash, version 4.4   #
#            by Weihang Lo             #
#             July. 2017               #
#--------------------------------------#

# Source global definitions
[[ -f /etc/bashrc ]] && . /etc/bashrc

#---------------------------------------
# User specific aliases and functions
#---------------------------------------
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ll='ls -lhF'

alias ports='lsof -PiTCP -sTCP:LISTEN'     # add sudo if needed
alias tree='tree -ACF --dirsfirst'

alias R='R --no-save --no-restore -q'
alias ipy='ipython3'
alias ipn='jupyter notebook'

[[ $(which atom-beta) ]] && alias atom='atom-beta'
[[ $(which apm-beta) ]] && alias apm='apm-beta'

# Update all Git repository under current directory
repo_update() {
    ls | while read i; do
        pushd $i > /dev/null
        echo "$i $(git remote update > /dev/null && git status -sb)"
        popd > /dev/null
        echo
    done
}


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
    [[ -f $(brew --prefix)/share/bash-completion/bash_completion ]] && \
    . $(brew --prefix)/share/bash-completion/bash_completion
else
    [[ $PS1 && -f /usr/share/bash-completion/bash_completion ]] && \
    . /usr/share/bash-completion/bash_completion
fi

# Android ANDROID_HOME -----------------
export ANDROID_HOME="$HOME/Library/Android/sdk"
export PATH="$ANDROID_HOME/tools/bin:$PATH"
export PATH="$ANDROID_HOME/platform-tools:$PATH"
alias emulator="$ANDROID_HOME/tools/emulator"

# Python3 configurations ---------------
# pyenv
#pyenv() {
#    unset -f pyenv
#    source <(pyenv init -)
#    pyenv $@
#}

# RUST ---------------------------------
export PATH="$HOME/.cargo/bin:$PATH"
export RUST_SRC_PATH="$(rustc --print sysroot)/lib/rustlib/src/rust/src"

# Ruby GEM_PATH ------------------------
export GEM_HOME="$HOME/.gem"
export PATH="$GEM_HOME/bin:$PATH"

# Node.js environment configuration ----
# NVM PATH and lazy loading
export NVM_DIR="$HOME/.nvm"
__lazy_nvm() { # (macOS only)
    local _NVM_SH=$(brew --prefix nvm)/nvm.sh
    [ -s $_NVM_SH ] && . $_NVM_SH
}

# load executable in alias=default
__find_node_globals() {
    default=`cat $NVM_DIR/alias/default`
    NODE_GLOBALS=(`find \
        $NVM_DIR/versions/node/$default/bin -type l -maxdepth 1 | \
        xargs -n 1 basename`)
    NODE_GLOBALS+=("node")
    NODE_GLOBALS+=("nvm")

    for cmd in "${NODE_GLOBALS[@]}"; do
        eval "${cmd}(){ unset -f ${NODE_GLOBALS[@]}; __lazy_nvm; ${cmd} \$@; }"
    done
    unset cmd
}

__find_node_globals # should load after bash completions

# fastlane intergration ----------------
[ -d ~/.fastlane ] && export PATH="$HOME/.fastlane/bin:$PATH"

#---------------------------------------
# Enhanced prompt
#---------------------------------------
__ssh_or_not() {
    if [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_TTY" ]]; then
        remote_hostname=[$HOSTNAME]
    else
        case $(ps -o comm= -p $PPID) in
            sshd|*/sshd)
                remote_hostname=[$HOSTNAME]
                ;;
        esac
    fi

    echo $remote_hostname
}

__git_branch() {
    ref=$(git symbolic-ref HEAD 2> /dev/null) || return
    status=$([[ $(git status -s) ]] && echo '*')
    stash=$([[ $(git stash list) ]] && echo '⚑')
    echo "( ${ref#refs/heads/}$status$stash)"
}

__git_last_commit() {
    now=$(date +%s);
    last_commit=$(git log --pretty=format:%at -1 2> /dev/null) || return;
    seconds=$((now - last_commit))
    minutes=$((seconds / 60))
    hours=$((minutes  / 60))
    days=$((hours / 24))

    minutes=$((minutes % 60))
    hours=$((hours % 24))

    if (( $days > 0)); then
        last_time="${days}d${hours}h"
    else
        last_time="${hours}h${minutes}m"
    fi

    echo $last_time
}

PS1="\`
    if [[ \$? = 0 ]]; then
        echo \[\e[1\;32m\]\"\W\" \
        \$(__ssh_or_not) \$(__git_branch) \$(__git_last_commit) \
        \☻ \[\e[0m\]
    else
        echo \[\e[1\;31m\]\"\W\" \
        \$(__ssh_or_not) \$(__git_branch) \$(__git_last_commit) \
        \✘ \[\e[0m\]
    fi\` "

PS2='... '

#-------------------
# Miscellaneous
#-------------------

# macOS local
if [[ $(uname) == "Darwin" ]]; then
    alias ls='ls -G'

    export LANG=en_US.UTF-8
    export LC_ALL=en_US.UTF-8
fi

[ -f ~/.fzf.bash ] && . ~/.fzf.bash
