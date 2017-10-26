#!/bin/bash

#---------------------------------------
# Creates symlinks to config files
#---------------------------------------

dir=$HOME/.dotfiles
origdir=$HOME/.dotfiles.orig

# put what you want to pre-install (Vundle, zsh...)
install_neovim_brew() { 
    brew install neovim
}

install_nvim_python() { 
    pip3 install neovim 
}

neovim_init() {
    ln -is $dir/.config/nvim/init.vim $HOME/.vimrc
}

add_bm_completion() {
    if [[ $(uname) == 'Darwin' ]]; then
        [ -d $(brew --prefix)/etc/bash_completion.d ] && \
        ln -is $HOME/.bm.sh \
            "$(brew --prefix)/etc/bash_completion.d/bm.sh"
    else
        [[ $PS1 && -d /etc/bash_completion.d ]] && \
        ln -is $HOME/.bm.sh /etc/bash_completion.d/bm.sh
    fi
}

install_tmux_package_manager() {
    if [[ ! -d "$HOME/.tmux/plugins/tpm" ]]; then
        git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    else
        echo 'TMUX Package Manager has already be installed.'
    fi
}

## put config/dir your want to sync in this variable
files="\
    .bashrc .inputrc .tmux.conf .bm.sh .gitignore .gitconfig \
    .vimrc .config/nvim/init.vim .xvimrc .nvm/default-packages \
    .Rprofile .ipython/profile_default/ipython_config.py"

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
    read -p "${3:-}Confirm $1? [y/N]" response
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
if [[ $(uname) == 'Darwin' ]]; then
    confirm 'install neovim' install_neovim_brew
    if [[ -f $(which 'pip3') ]]; then
        confirm 'install nvim-python' install_nvim_python
    fi
fi

confirm "replace .vimrc by neovim's init.vim" neovim_init
confirm "add bash-completion for bm (bookmark manager)" add_bm_completion
confirm "install tpm (TMUX Package Manager)" install_tmux_package_manager
