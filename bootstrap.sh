#!/usr/bin/env bash
#--------------------------------------#
#    Boostrap all your config files    #
#            by Weihang Lo             #
#              Dec. 2021               #
#--------------------------------------#

# Define source and backup directory

dir=$HOME/.dotfiles
origdir=$HOME/.dotfiles.orig

# --------------------------------------
# Put config/dir to sync in this variable
# --------------------------------------

files=(
    .bashrc
    .cargo/config.toml
    .config/alacritty/alacritty.yml
    .config/fish/config.fish
    .config/kitty/kitty.conf
    .config/nvim/init.vim
    .config/nvim/lua/dap-configs.lua
    .config/nvim/lua/lsp.lua
    .config/nvim/lua/plugins.lua
    .config/ripgreprc
    .config/starship.toml
    .gitconfig
    .gitignore
    .inputrc
    .tmux.conf
)

# --------------------------------------
# Put custom installaltion commands here
# --------------------------------------

install_cargo_binaries() {
  crates=(
    bat
    cargo-update
    exa
    fd-find
    git-delta
    gitui
    mdbook
    ripgrep
    starship
    tealdeer
    tokei
    watchexec-cli
    zoxide
  )

  cargo install ${crates[@]}
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

confirm "install tpm (TMUX Package Manager)" install_tmux_package_manager
confirm "install all goods from cargo" install_cargo_binaries
