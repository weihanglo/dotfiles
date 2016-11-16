#!/bin/bash

#---------------------------------------
# Creates symlinks to config files
#---------------------------------------

dir=$HOME/.linux-config
origdir=$HOME/.linux-config.orig

# put what you want to pre-install (Vundle, zsh...)
function install_neovim_brew { 
    brew install neovim/neovim/neovim 
}

function install_nvim_python { 
    pip3 install neovim 
}

function neovim_init {
    ln -is $dir/.config/nvim/init.vim $HOME/.vimrc
}


function add_bm_completion {
    if [[ $(uname) == "Darwin" ]]; then
        [ -d $(brew --prefix)/etc/bash_completion.d ] && \
        ln -s $HOME/.bm.bash \
            "$(brew --prefix)/etc/bash_completion.d/bm.bash"
    else
        [ $PS1 && -d /etc/bash_completion.d ] && \
        ln -s $HOME/.bm.bash /etc/bash_completion.d/bm.bash
    fi
}




## put config/dir your want to sync in this variable
files="\
    .bashrc .inputrc .tmux.conf .bm.bash \
    .gitignore .gitconfig \
    .vimrc .vimperatorrc .vimperator/colors/solarized_dark.vimp \
    .config/nvim/init.vim .xvimrc \
    .Rprofile .pythonrc.py .ipython/profile_default/ipython_config.py"


echo -n "Creating $origdir for backup ..."
mkdir -p $origdir
echo "done"


echo -n "cd to $dir ..."
cd $dir
echo "done"


for file in $files; do
    echo "Moving $file to $origdir"
    mkdir -p $HOME/$(dirname $file)
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
            $2
            ;;
        *)
            echo "Operation aborted."
            ;;
    esac
    echo
}


# confirm installation
if [[ $(uname) == "Darwin" ]]; then

    confirm 'Install neovim' install_neovim_brew

    if [[ -f $(which 'pip3') ]]; then
        confirm 'Install nvim-python' install_nvim_python
    fi
fi

confirm "Replace .vimrc by neovim's init.vim" neovim_init

confirm "Add bash-completion for bm (bookmark manager)" add_bm_completion