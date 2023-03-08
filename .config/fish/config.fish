#!/usr/bin/env fish

#--------------------------------------#
#   configs for fish shell, version 3  #
#            by Weihang Lo             #
#              Mar. 2023               #
#--------------------------------------#

# Default shell to fish
set -gx SHELL fish

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
    # FZF
    set -gx FZF_DEFAULT_COMMAND "rg --files --smart-case"
    set -pgx PATH $HOME/.fzf/bin
    # Rust
    set -pgx PATH $HOME/.cargo/bin

    # Load `rtx` once and for all. A replacement for
    # - go
    # - nvm (fnm)
    # - opam
    # - pyenv
    # - rbenv
    type -q rtx; and rtx activate fish | source
end

# ------------------------------------------------------------------------------
# Load only for interative shell.
# ------------------------------------------------------------------------------

if status is-interactive
    alias cat="bat"
    alias ll="exa -lhgF --git"
    alias ls="exa"
    alias ipy="ipython"
    alias ports="lsof -PiTCP -sTCP:LISTEN"
    alias tree="exa -TF --group-directories-first"
    alias k="kubectl"
    alias P="fish -P"
    # Customizable prompt
    starship init fish | source
    # A smarter cd command
    type -q zoxide; and zoxide init fish | source
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
