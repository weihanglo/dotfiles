#!/usr/bin/env zsh

#--------------------------------------#
#    .zshrc but I seldom use zshell    #
#            by Weihang Lo             #
#              Aug. 2023               #
#--------------------------------------#

# ------------------------------------------------------------------------------
# Load only for interative shell.
# ------------------------------------------------------------------------------

if [[ -o interactive ]]; then
    source "$HOME/.shalias"
    # Customizable prompt
    eval "$(starship init zsh)"
    # A smarter cd command
    hash zoxide && eval "$(zoxide init zsh)"
    # A smarter history management
    hash atuin && eval "$(atuin init zsh --disable-up-arrow)"

    # TODO: add auto-completion integration
fi
