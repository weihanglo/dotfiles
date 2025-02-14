#!/usr/bin/env bash
#--------------------------------------#
#    Boostrap all your config files    #
#            by Weihang Lo             #
#              Feb. 2025               #
#--------------------------------------#

SCRIPTPATH="$( cd "$(dirname "$0")" && pwd -P )"

# --------------------------------------
# Put config/dir to sync in this variable
# --------------------------------------

readonly files_to_sync=(
    .config/kitty/current-theme.conf
    .config/kitty/kitty.conf
    .config/nvim/init.vim
    .config/nvim/lazy-lock.json
    .config/nvim/lua/lsp.lua
    .config/nvim/lua/plugins.lua
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
  esac
else
  confirm "Synchronize all config files" sync_config_files
fi
