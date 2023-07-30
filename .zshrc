#!/usr/bin/env zsh

#--------------------------------------#
#    .zshrc but I seldom use zshell    #
#            by Weihang Lo             #
#              July 2023               #
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
fi

# TODO: add auto-completion integration

# ------------------------------------------------------------------------------
# Commands that always run for all sessions go below.
# ------------------------------------------------------------------------------

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
