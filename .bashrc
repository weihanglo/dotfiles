#!/bin/bash
# Source global definitions
if [[ -f /etc/bashrc ]]; then
    . /etc/bashrc
fi

#---------------------------------------
# User specific aliases and functions
#---------------------------------------
alias cdd='cd ~/Desktop'
alias cdw='cd ~/wd'
alias ..='cd ..'
alias ...='cd ../..'
alias ll='ls -lh'

alias ports='lsof -PiTCP -sTCP:LISTEN'     # add sudo if needed
alias share='python3 -m http.server'

alias sshfml1='ssh -Yp 10022 $FML'
alias sftpfml1='sftp -P 10022 $FML'
alias sshfml2='ssh -Yp 20022 $FML'
alias sftpfml2='sftp -P 20022 $FML'
alias sshlopen131='ssh -Y $LOPEN1'
alias sshlopen132='ssh -Y $LOPEN2'

alias R='R --no-save --no-restore -q'
alias ipy='ipython3'
alias ipn='jupyter notebook'
alias py3='python3'
alias nv='nvim'
if [[ $(which vimx) ]]; then
    alias vim='vimx'
fi

#---------------------------------------
# Environment variables
#---------------------------------------
# SSH servers
export FML='lowh@fml1.fo.ntu.edu.tw'
export LOPEN1='140.112.147.131'
export LOPEN2='140.112.147.132'

# EDITOR and VISUAL
if [[ -f $(which 'nvim') ]]; then
    export VISUAL=nvim
    export EDITOR=nvim
elif [[ -f $(which 'vimx') ]]; then
    export VISUAL=vimx
    export EDITOR=vimx
else
    export VISUAL=vim
    export EDITOR=vim
fi

# Python3 startup ----------------------
if [[ -f $HOME/.pythonrc.py ]]; then
    export PYTHONSTARTUP=$HOME/.pythonrc.py
fi

# Ruby GEM_PATH ------------------------
export GEM_HOME=$HOME/.gem
export PATH=$GEM_HOME/bin:$PATH

# History setting ----------------------
export HISTFILESIZE=
export HISTSIZE=
export HISTCONTROL=ignoreboth
export PROMPT_COMMAND='history -a'


#---------------------------------------
# Enhanced prompt
#---------------------------------------
function ssh_or_not {
    if [[ -n "$SSH_CLIENT" ]] || [[ -n "$SSH_TTY" ]]; then
        echo [$HOSTNAME]
    else
        case $(ps -o comm= -p $PPID) in
            sshd|*/sshd)
            echo [$HOSTNAME]
        esac
    fi
}

function git_branch {
    ref=$(git symbolic-ref HEAD 2> /dev/null) || return
    echo "( "${ref#refs/heads/}")"
}

function git_since_last_commit {
    now=`date +%s`;
    last_commit=$(git log --pretty=format:%at -1 2> /dev/null) || return;
    seconds_since_last_commit=$((now-last_commit));
    minutes_since_last_commit=$((seconds_since_last_commit/60));
    hours_since_last_commit=$((minutes_since_last_commit/60));
    minutes_since_last_commit=$((minutes_since_last_commit%60));
    
    echo "${hours_since_last_commit}h${minutes_since_last_commit}m ";
}

#---------------------------------------
# Colorful prompt
#---------------------------------------
PS1="\`
    if [[ \$? = 0 ]];
    then
        echo \[\e[1m\]\[\e[32m\]\W \
        \$(ssh_or_not) \$(git_branch) \$(git_since_last_commit) \
        \➤ \[\e[m\]
    else
        echo \[\e[1m\]\[\e[31m\]\W \
        \$(ssh_or_not) \$(git_branch) \$(git_since_last_commit) \
        \➤ \[\e[m\]
    fi\` "

PS2='... '

#-------------------
# Vi mode in bash
#-------------------
# old: set -o vi
# new: create a file named ".inputrc" in home
#      set editing-mode vi
#      set keymap vi-command

#-------------------
# OSX specified
#-------------------
if [[ $(uname) == "Darwin" ]]; then
    alias ls='ls -G'

    # Change locale
    export LANG=en_US.UTF-8¬
    export LC_ALL=en_US.UTF-8

    # source bash_completion
    if [[ -f $(brew --prefix)/etc/bash_completion ]]; then
        . $(brew --prefix)/etc/bash_completion
    fi
fi

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
