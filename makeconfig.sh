#!/bin/bash

#---------------------------------------
# Creates symlinks to config files
#---------------------------------------

dir=~/.linux-config
origdir=~/.linux-config.orig

install_vundle="git clone https://github.com/VundleVim/Vundle.vim.git \
    ~/.vim/bundle/Vundle.vim"

# put config/dir your want to sync in this variable
files=".bashrc .vimrc .vim .vimperatorrc .tmux.conf .tmuxline .Rprofile \
    .pythonrc .gitignore .gitconfig" 

echo -n "Creating $origdir for backup ..."
mkdir -p $origdir
echo "done"

echo -n "cd to $dir ..."
cd $dir
echo "done"

for file in $files; do
    echo "Moving dotfiles from ~ to $origdir"
    mv ~/$file ~/$origdir
    echo "Creating symlink to $file in ~/"
    ln -s $dir/$file ~/$file
done


# confirm before install
confirm () {
    # call with a prompt string or use a default
    read -r -p "${3:-Install $1? [y/N]} " response
    case $response in
        [yY][eE][sS]|[yY]) 
        eval $2
            ;;
        *)
        echo "Operation aborted."
            ;;
    esac
}

confirm() Vundle '$install_vundle'
