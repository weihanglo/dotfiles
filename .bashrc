# .bashrc
# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific aliases and functions
alias sshfml1='ssh -Yp 10022 lowh@fml1.fo.ntu.edu.tw'
alias sftpfml1='sftp -P 10022 lowh@fml1.fo.ntu.edu.tw'
alias mysqlfml1='mysql -u lamminator -h fml1.fo.ntu.edu.tw -p -P 13306'
alias sshfml2='ssh -Yp 20022 lowh@fml1.fo.ntu.edu.tw'
alias sftpfml2='sftp -P 20022 lowh@fml1.fo.ntu.edu.tw'
alias mysqlfml2='mysql -u lamminator -h fml1.fo.ntu.edu.tw -p -P 23306'
alias vim='vimx --servername VIM'
alias R='R --no-save --no-restore -q'
alias ipy='ipython3'
alias ipynb='ipython notebook'
alias py3='python3'
alias phpmyadmin='firefox http://127.0.0.1/phpmyadmin/'


#---------------------------------------
# enhanced prompt
#---------------------------------------

# ssh or not
function ssh_or_not {
    ip=$(who am i |awk '{printf $5}')
    if [ $ip ]; then echo [$HOSTNAME]; fi
}


# parse git branch
function parse_git_branch {
    ref=$(git symbolic-ref HEAD 2> /dev/null) || return
    echo "( "${ref#refs/heads/}")"
}

# colorful prompt
PS1="\`
    if [ \$? = 0 ];
    then
        echo \[\e[1m\]\[\e[32m\]\W \
        \$(ssh_or_not) \$(parse_git_branch) \
        \➤ \[\e[m\]
    else
        echo \[\e[1m\]\[\e[31m\]\W \
        \$(ssh_or_not) \$(parse_git_branch) \
        \➤ \[\e[m\]
    fi\` "

PS2='... '



#-------------------
# python3 startup
#-------------------

if [ -f $HOME/.pythonrc.py ]
then
    export PYTHONSTARTUP=$HOME/.pythonrc.py
fi


#-------------------
# vi mode in bash
#-------------------
# old: set -o vi
# new: create a file named ".inputrc" in home
#      set editing-mode vi
#      set keymap vi-command
