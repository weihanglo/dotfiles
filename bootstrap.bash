#!/usr/bin/env bash
#--------------------------------------#
#    Boostrap all your config files    #
#            by Weihang Lo             #
#              Dec. 2021               #
#--------------------------------------#

# --------------------------------------
# Put config/dir to sync in this variable
# --------------------------------------

files_to_sync=(
    .bashrc
    .cargo/config.toml
    .config/alacritty/alacritty.yml
    .config/bat/config
    .config/fish/config.fish
    .config/gitui/key_bindings.ron
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

cargo_crates=(
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

python_packages=(
  ipython
  pipenv
  poetry
  python-lsp-server[all]
)

# --------------------------------------
# Put custom installaltion commands here
# --------------------------------------

sync_config_files () {
  # Define source and backup directory
  dir=$HOME/.dotfiles
  origdir=$HOME/.dotfiles.orig

  echo -n "Creating $origdir for backup ..."
  mkdir -p $origdir
  echo "done"

  echo -n "cd to $dir ..."
  cd $dir
  echo "done"

  # Symlink files
  for file in ${files_to_sync[@]}; do
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
}

install_tmux_package_manager() {
    tpm_dir="$HOME/.tmux/plugins/tpm"
    if [[ ! -d "$tpm_dir" ]]; then
        git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
    else
        echo 'TMUX Package Manager has already be installed.'
    fi
}

install_cargo_binaries() {
  cargo install ${cargo_crates[@]}
}

install_python_binaries() {
  python3 -m pip install -U pipx pip
  python3 -m pipx ensurepath
  echo ${python_packages[@]} | xargs -n1 python3 -m pipx install
}

# confirm helper function running before installation
confirm () {
    echo
    read -p "${3:-}$1? [y/N]" response
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

# ----------------------------------------
# Main function that calls other functions
# ----------------------------------------

if [[ -n "$1" ]]; then
  case "$1" in
    sync)
      sync_config_files
      ;;
    tpm)
      install_tmux_package_manager
      ;;
    cargo|rust)
      install_cargo_binaries
      ;;
    python|py)
      install_python_binaries
      ;;
  esac
else
  confirm "Synchronize all config files" sync_config_files
  confirm "Install tpm (TMUX Package Manager)" install_tmux_package_manager
  confirm "Install all goods from cargo" install_cargo_binaries
  confirm "Install useful python binaries" install_python_binaries
fi
