#!/usr/bin/env bash
#--------------------------------------#
#    Boostrap all your config files    #
#            by Weihang Lo             #
#              Oct. 2020               #
#--------------------------------------#

# Define source and backup directory

dir=$HOME/.dotfiles
origdir=$HOME/.dotfiles.orig

# --------------------------------------
# Put config/dir to sync in this variable
# --------------------------------------

files=(
    .bashrc
    .bm.sh
    .cargo/config.toml
    .config/alacritty/alacritty.yml
    .config/fish/config.fish
    .config/kitty/kitty.conf
    .config/nvim/autoload/taiwanese_proverbs.vim
    .config/nvim/init.vim
    .config/nvim/lua/language_server.lua
    .config/starship.toml
    .gitconfig
    .gitignore
    .inputrc
    .ipython/profile_default/ipython_config.py
    .nvm/default-packages
    .tmux.conf
    .vimrc
)

# --------------------------------------
# Put custom installaltion commands here
# --------------------------------------

install_neovim() {
    brew install neovim || brew upgrade neovim 
}

install_nvim_python() {
    pip3 install -U neovim pynvim
}

install_ripgrep() {
    cargo install ripgrep
}

install_starship() {
    cargo install starship
}

install_git_delta() {
    cargo install git-delta
}

neovim_replace_vimrc() {
    ln -is $dir/.config/nvim/init.vim $HOME/.vimrc
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
    echo -e "\tMoving $file to $origdir/$file"
    if [[ -z "$file" ]]; then
        echo -e "No file $file found"
        return
    fi
    mkdir -p "$HOME/$(dirname $file)"
    mkdir -p "$origdir/$(dirname $file)"
    mv "$HOME/$file" "$origdir/$file"
    echo -e "\tSymlinking to $file in $dir"
    ln -is "$dir/$file" "$HOME/$file"
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
    confirm 'install neovim' install_neovim
    if [[ -f $(which 'pip3') ]]; then
        confirm 'install nvim-python' install_nvim_python
    fi
fi

confirm "replace .vimrc by neovim's init.vim" neovim_replace_vimrc
confirm "install tpm (TMUX Package Manager)" install_tmux_package_manager
confirm "install ripgrep, a better grep" install_ripgrep
confirm "install starship, prompt with sane defaults" install_starship
confirm "install delta, diff viewer with joy" install_git_delta
