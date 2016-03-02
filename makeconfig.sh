#!/bin/bash

#---------------------------------------
# Creates symlinks to config files
#---------------------------------------

dir=~/.linux-config
origdir=~/.linux-config.orig

# put what you want to pre-install (Vundle, zsh...)
install_neovim_brew="brew install neovim/neovim/neovim"
install_nvim-python="pip3 install neovim"


# put config/dir your want to sync in this variable
files=".bashrc .vimrc .vimperatorrc .vimperator/colors/molokai.vimp .tmux.conf \
    .tmuxline .Rprofile .pythonrc.py .inputrc .gitignore .gitconfig"


echo -n "Creating $origdir for backup ..."
mkdir -p $origdir
echo "done"


echo -n "cd to $dir ..."
cd $dir
echo "done"


for file in $files; do
    echo "Moving $file to $origdir"
    mv ~/$file $origdir
    echo "Symlinking to $file in $dir"
    ln -s $dir/$file ~/$file
done


# confirm before install
confirm () {
    echo
    read -r -p "${3:-Install $1? [y/N]} " response
    case $response in
        [yY][eE][sS]|[yY])
        eval $2
            ;;
        *)
        echo "Operation aborted."
            ;;
    esac
    echo
}


# confirm installation
if [[ $(uname) == "Darwin" ]]; then

    confirm neovim '$install_neovim_brew'

    if [[ -f $(which 'pip3') ]]; then
        confirm nvim-python '$install_nvim_python'
    fi
fi
