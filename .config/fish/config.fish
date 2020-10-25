#!/usr/bin/env fish

#--------------------------------------#
#   configs for fish shell, version 3  #
#            by Weihang Lo             #
#              Oct. 2020               #
#--------------------------------------#

if set -q config_fish_loaded
    # config.fish has already loaded.
    # source starship again before failing fast
    starship init fish | source
    exit
end
set -gx config_fish_loaded

#---------------------------------------
# User specific aliases and functions
#---------------------------------------
function ls -d 'Alias ls to exa.'
    exa $argv
end

function ll -d 'Alias ll to exa for `ls -l` with git status.'
    exa -lhgF --git $argv
end

function ports -d 'List all listening TCP ports. Add sudo if needed.'
    lsof -PiTCP -sTCP:LISTEN $argv
end

function tree -d 'Alias tree to exa'
    exa -TF --group-directories-first $argv
end

function cat -d 'Alias cat to bat'
    bat $argv
end

#---------------------------------------
# Environment variables and configs
#---------------------------------------
# Default shell to fish
set -gx SHELL fish

# LESS pager. More power.
set -gx LESS "isFMRX"

# Aditional PATHs
set -gx fish_user_paths "$HOME/.local/bin" $fish_user_paths

# EDITOR and VISUAL
set -gx VISUAL nvim 
set -gx EDITOR nvim

# Ruby GEM_PATH
set -gx GEM_HOME "$HOME/.gem"
set -gx fish_user_paths "$GEM_HOME/bin" $fish_user_paths

# Golang environment
set -gx GOPATH "$HOME/.go"
set -gx fish_user_paths "$GOPATH/bin" $fish_user_paths

# Python
set -gx PYENV_ROOT "$HOME/.pyenv"
set -gx fish_user_paths "$PYENV_ROOT/bin" "$fish_user_paths"
set -gx PIPENV_PYTHON "$PYENV_ROOT/shims/python"
pyenv init - | source

# RUST
set -gx fish_user_paths "$HOME/.cargo/bin" $fish_user_paths

# Just launch the starship!!! (https://starship.rs/)
starship init fish | source

# FZF default configs
set FZF_DEFAULT_COMMAND "rg --files --smart-case"
set PATH $PATH "$HOME/.fzf/bin"
