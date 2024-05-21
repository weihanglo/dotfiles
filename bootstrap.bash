#!/usr/bin/env bash
#--------------------------------------#
#    Boostrap all your config files    #
#            by Weihang Lo             #
#              Feb. 2024               #
#--------------------------------------#

SCRIPTPATH="$( cd "$(dirname "$0")" && pwd -P )"

# --------------------------------------
# Put config/dir to sync in this variable
# --------------------------------------

readonly files_to_sync=(
    .bashrc
    .cargo/config.toml
    .config/alacritty/alacritty.yml
    .config/atuin/config.toml
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
    .config/zellij/config.kdl
    .gitconfig
    .gitignore
    .inputrc
    .shalias
    .shenv
    .zshenv
    .zshrc
)

readonly cargo_crates=(
  atuin
  bat
  cargo-update
  difftastic
  eza
  fd-find
  git-delta
  gitui
  hyperfine
  mdbook
  procs
  ripgrep
  starship
  tealdeer
  tokei
  watchexec-cli
  zellij
  zoxide
)

python_packages=(
  ipython
  pipenv
  poetry
  'python-lsp-server[all]'
)

# --------------------------------------
# Put custom installaltion commands here
# --------------------------------------

sync_config_files () {
  # Define source and backup directory
  dir=$SCRIPTPATH
  origdir=$HOME/.dotfiles.orig

  echo "Creating $origdir for backup old dotfiles ..."
  mkdir -vp "$origdir"

  echo "cd to $dir ..."
  pushd "$dir" || exit 1

  # Symlink files
  for file in "${files_to_sync[@]}"; do
      if [[ -z "$file" ]]; then
          echo -e "Failed to move $file to $origdir/$file: No file $file found"
          return
      fi
      mkdir -p "$HOME/$(dirname "$file")"
      mkdir -p "$origdir/$(dirname "$file")"
      mv -v "$HOME/$file" "$origdir/$file"
      ln -ivs "$dir/$file" "$HOME/$file"
  done

  popd || exit 1
}

install_cargo_binaries() {
  cargo install "${cargo_crates[@]}" --locked
}

install_python_binaries() {
  python3 -m pip install -U pipx pip
  python3 -m pipx ensurepath
  echo "${python_packages[@]}" | xargs -n1 python3 -m pipx install
}

# confirm helper function running before installation
confirm () {
    echo
    read -r -p "${3:-}$1? [y/N]" response
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
    cargo|rust)
      install_cargo_binaries
      ;;
    python|py)
      install_python_binaries
  esac
else
  confirm "Synchronize all config files" sync_config_files
  confirm "Install all goods from cargo" install_cargo_binaries
  confirm "Install useful python binaries" install_python_binaries
fi
