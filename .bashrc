# .bashrc
# Source global definitions
if [ -f /etc/bashrc ]; then
	. /etc/bashrc
fi

# User specific aliases and functions
alias shut='sync;sync;sync;sudo shutdown now'
alias sshfml1='ssh -p 10022 lowh@fml1.fo.ntu.edu.tw'
alias sftpfml1='sftp -P 10022 lowh@fml1.fo.ntu.edu.tw'
alias mysqlfml1='mysql -u lamminator -h fml1.fo.ntu.edu.tw -p'
alias vim='vimx --servername VIM'
alias R='R --no-save --no-restore -q'
alias ipy='ipython3'
alias ipynb='ipython notebook'
alias py3='python3'
alias phpmyadmin='firefox http://127.0.0.1/phpmyadmin/'
#alias flask='source $HOME/wd/flask/bin/activate; cd $HOME/wd/flask'

#---------------------------------------
# enhanced prompt
#---------------------------------------

# ssh or not
ssh_or_not () {
    ip=$(who am i |awk '{printf $5}')
    if [ $ip ]; then echo [$HOSTNAME]; fi
}


# parse git branch
parse_git_branch () {
    ref=$(git symbolic-ref HEAD 2> /dev/null) || return
    echo "( "${ref#refs/heads/}")"
}

# colorful prompt
PS1="\n\`
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

if [ -f $HOME/.pythonrc ]
then
    export PYTHONSTARTUP=$HOME/.pythonrc
fi


#-------------------
# vi mode in bash
#-------------------
# old: set -o vi
# new: create a file named ".inputrc" in home
#      set editing-mode vi
#      set keymap vi-command
