#!/bin/bash
#--------------------------------------#
#    Boostrap all your config files    #
#            by Weihang Lo             #
#              Oct. 2017               #
#--------------------------------------#

# Unoffical strict mode
# Reference: http://redsymbol.net/articles/unofficial-bash-strict-mode/
set -euo pipefail
IFS=$'\n\t'

# Define source and backup directory

dir=$HOME/.dotfiles
origdir=$HOME/.dotfiles.orig

# --------------------------------------
# Put config/dir to sync in this variable
# --------------------------------------

files=(
    .Rprofile
    .bashrc
    .bm.sh
    .config/alacritty/alacritty.yml
    .config/nvim/init.vim
    .gitconfig
    .gitignore
    .inputrc
    .ipython/profile_default/ipython_config.py
    .nvm/default-packages
    .tern-config
    .tmux.conf
    .vimrc
    .xvimrc
)

# --------------------------------------
# Put custom installaltion commands here
# --------------------------------------

install_neovim_brew() {
    brew install neovim
}

install_nvim_python() {
    pip3 install neovim
}

install_ripgrep() {
    cargo install ripgrep
}

neovim_replace_vimrc() {
    ln -is $dir/.config/nvim/init.vim $HOME/.vimrc
}

add_bm_completion() {
    if [[ $(uname) == 'Darwin' ]]; then
        [ -d $(brew --prefix)/etc/bash_completion.d ] && \
        ln -is $HOME/.bm.sh \
            "$(brew --prefix)/etc/bash_completion.d/bm.sh"
    else
        [[ ${PS1} && -d /etc/bash_completion.d ]] && \
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

# --------------------------------------
# Start symlink files
# --------------------------------------

echo -n "Creating $origdir for backup ..."
mkdir -p $origdir
echo "done"

echo -n "cd to $dir ..."
cd $dir
echo "done"

# Symlink files
for file in ${files[@]}; do
    echo "$file"
    echo -e "\tMoving $file to $origdir"
    mkdir -p $HOME/$(dirname $file)
    mv $HOME/$file $origdir
    echo -e "\tSymlinking to $file in $dir"
    ln -is $dir/$file $HOME/$file
done

# --------------------------------------
# Call pre-defined custom commmands here
# --------------------------------------

# confirm helper function running before installation
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

confirm "replace .vimrc by neovim's init.vim" neovim_replace_vimrc
confirm "add bash-completion for bm (bookmark manager)" add_bm_completion
confirm "install tpm (TMUX Package Manager)" install_tmux_package_manager
confirm "install ripgrep, a better grep" install_ripgrep
