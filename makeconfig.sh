#!/bin/bash

#---------------------------------------
# Creates symlinks to config files
#---------------------------------------

dir=$HOME/.linux-config
origdir=$HOME/.linux-config.orig

# put what you want to pre-install (Vundle, zsh...)
install_neovim_brew="brew install neovim/neovim/neovim"
install_nvim_python="pip3 install neovim"
neovim_init="ln -is $dir/.config/nvim/init.vim $HOME/.vimrc"



## put config/dir your want to sync in this variable
files=".bashrc .vimrc .vimperatorrc .vimperator/colors/molokai.vimp \
    .tmux.conf .Rprofile .pythonrc.py .inputrc .gitignore .gitconfig \
    .config/nvim/init.vim .xvimrc"


echo -n "Creating $origdir for backup ..."
mkdir -p $origdir
echo "done"


echo -n "cd to $dir ..."
cd $dir
echo "done"


for file in $files; do
    echo "Moving $file to $origdir"
    mv $HOME/$file $origdir
    echo "Symlinking to $file in $dir"
    ln -is $dir/$file $HOME/$file
done


# confirm before install
confirm () {
    echo
    read -r -p "${3:-Confirm $1? [y/N]} " response
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

    confirm 'Install neovim' '$install_neovim_brew'

    if [[ -f $(which 'pip3') ]]; then
        confirm 'Install nvim-python' '$install_nvim_python'
    fi
fi

confirm "Replace .vimrc by neovim's init.vim" '$neovim_init'
