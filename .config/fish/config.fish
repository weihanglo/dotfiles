#!/usr/bin/env fish

#--------------------------------------#
#   configs for fish shell, version 3  #
#            by Weihang Lo             #
#              Aug. 2023               #
#--------------------------------------#

# Default shell to fish
set -gx SHELL (command -v fish)

# ------------------------------------------------------------------------------
# Run for login shell.
# ------------------------------------------------------------------------------

if status is-login
    # LESS pager. More power.
    set -gx LESS isFMRX
    # EDITOR and VISUAL
    set -gx EDITOR nvim
    set -gx VISUAL nvim 
    # Set locale
    set -gx LC_ALL en_US.UTF-8

    # Ripgrep config
    set -gx RIPGREP_CONFIG_PATH $HOME/.config/ripgreprc
    # Additional PATHs
    set -agx PATH $HOME/.local/bin
    # Rust
    set -pgx PATH $HOME/.cargo/bin
end

# ------------------------------------------------------------------------------
# Load only for interative shell.
# ------------------------------------------------------------------------------

if status is-interactive
    alias cat="bat"
    alias ll="eza -lhgF --git"
    alias ls="eza"
    alias ipy="ipython"
    alias ports="lsof -PiTCP -sTCP:LISTEN"
    alias tree="eza -TF --group-directories-first"
    alias k="kubectl"
    alias P="fish -P"
    # Customizable prompt
    starship init fish | source
    # A smarter cd command
    type -q zoxide; and zoxide init fish | source
    # A smarter history management
    type -q atuin; and atuin init fish --disable-up-arrow | source
end

# ------------------------------------------------------------------------------
# Commands that always run for all sessions go below.
# ------------------------------------------------------------------------------

# A ninja in starship!
if test $fish_private_mode
    set -x __PRIVATE_MODE 🥷
else
    set -e __PRIVATE_MODE
end
