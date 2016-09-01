#!/bin/bash

#--------------------------------------#
#  .bashrc for GNU bash, version 4.3   #
#            by Weihang Lo             #
#             August 2016              #
#--------------------------------------#

# Source global definitions
[[ -f /etc/bashrc ]] && . /etc/bashrc

#---------------------------------------
# User specific aliases and functions
#---------------------------------------
alias cdd='cd ~/Desktop/'
alias cdl='cd ~/Downloads/'
alias cdw='cd ~/Documents/works/Git/'
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ll='ls -lhF'

alias sshfml1='ssh -Yp 10022 ${FML}'
alias sshfml2='ssh -Yp 20022 ${FML}'
alias sshfml3='ssh -Yp 30022 ${FML}'
alias sftpfml1='sftp -P 10022 ${FML}'
alias sftpfml2='sftp -P 20022 ${FML}'
alias sftpfml3='sftp -P 30022 ${FML}'

alias ports='lsof -PiTCP -sTCP:LISTEN'     # add sudo if needed
alias pyserver='python3 -m http.server'
alias tree='tree -ACF'

alias R='R --no-save --no-restore -q'
alias ipy='ipython3'
alias ipn='jupyter notebook'
alias py3='python3'

if [[ $(which vimx) ]]; then
    alias vim='vimx'
fi

function load_nvm {
    [[ $(uname) == "Darwin" ]] && . $(brew --prefix nvm)/nvm.sh
}

function pkgupdate {
    if [[ $(uname) == "Darwin" ]]; then
        brew update && brew upgrade
    elif [[ -f /etc/debian_version ]]; then
        sudo apt-get update -y && sudo apt-get upgrade -y
    else
        sudo dnf upgrade -y
    fi
}

function podreinstall {
    [ -d Pods ] && rm -rf Pods Podfile.lock *.xcworkspace && pod install
}

# Update all Git repository under current directory
function repoupdate {
    ls | while read i; do
        pushd $i > /dev/null
        echo "$i $(git remote update > /dev/null && git status -sb)"
        popd > /dev/null
    done
}


#---------------------------------------
# Environment variables and configs
#---------------------------------------
# Aditional PATHs
export PATH=$HOME/.local/bin:$PATH

# SSH servers
export FML='lowh@fml1.fo.ntu.edu.tw'

# EDITOR and VISUAL
if [[ -f $(which 'nvim') ]]; then
    export VISUAL=nvim EDITOR=nvim
elif [[ -f $(which 'vimx') ]]; then
    export VISUAL=vimx EDITOR=vimx
else
    export VISUAL=vim EDITOR=vim
fi

# Python3 startup ----------------------
[[ -f $HOME/.pythonrc.py ]] && export PYTHONSTARTUP=$HOME/.pythonrc.py

# Python3 virtualenvwrapper
if [[ -f /usr/loca/bin/virtualenvwrapper.sh ]]; then
    export WORKON_HOME=$HOME/.virtualenvs
    export VIRTUALENVWRAPPER_PYTHON=/usr/local/bin/python3
    export VIRTUALENVWRAPPER_SCRIPT=/usr/local/bin/virtualenvwrapper.sh
    source /usr/local/bin/virtualenvwrapper_lazy.sh
fi

# Ruby GEM_PATH ------------------------
export GEM_HOME=$HOME/.gem
export PATH=$GEM_HOME/bin:$PATH

# NVM PATH (mac only) ------------------
export NVM_DIR=$HOME/.nvm

# History setting ----------------------
export HISTFILESIZE=
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


#---------------------------------------
# Enhanced prompt
#---------------------------------------
function __ssh_or_not {
    if [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_TTY" ]]; then
        remote_hostname=[$HOSTNAME]
    else
        case $(ps -o comm= -p $PPID) in
            sshd|*/sshd)
                remote_hostname=[$HOSTNAME]
                ;;
        esac
    fi

    echo ${remote_hostname}
}

function __git_branch {
    ref=$(git symbolic-ref HEAD 2> /dev/null) || return
    echo "( "${ref#refs/heads/}")"
}

function __git_last_commit {
    now=$(date +%s);
    last_commit=$(git log --pretty=format:%at -1 2> /dev/null) || return;
    seconds=$((now-last_commit))
    minutes=$((seconds / 60))
    hours=$((minutes  / 60))
    days=$((hours / 24))

    minutes=$((minutes % 60))
    hours=$((hours % 24))

    if (( ${days} > 0)); then
        last_time="${days}d${hours}h"
    else
        last_time="${hours}h${minutes}m"
    fi

    echo ${last_time}
}

PS1="\`
    if [[ \$? = 0 ]]; then
        echo \[\e[1m\]\[\e[32m\]\W \
        \$(__ssh_or_not) \$(__git_branch) \$(__git_last_commit) \
        \➤ \[\e[m\]
    else
        echo \[\e[1m\]\[\e[31m\]\W \
        \$(__ssh_or_not) \$(__git_branch) \$(__git_last_commit) \
        \➤ \[\e[m\]
    fi\` "

PS2='... '

#-------------------
# OSX specified
#-------------------
if [[ $(uname) == "Darwin" ]]; then
    alias ls='ls -G'

    # Change locale
    export LANG=en_US.UTF-8¬
    export LC_ALL=en_US.UTF-8
fi

[ -f ~/.fzf.bash ] && . ~/.fzf.bash
