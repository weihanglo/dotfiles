#!/usr/bin/env zsh

#--------------------------------------#
#   .zshenv but I seldom use zshell    #
#            by Weihang Lo             #
#              Aug. 2023               #
#--------------------------------------#

# Default shell to zsh
export SHELL=$(command -v zsh)

# ------------------------------------------------------------------------------
# Run for login shell.
# ------------------------------------------------------------------------------

if [[ -o login ]]; then
    source "$HOME/.shenv"
    # Load `rtx` once and for all.
    hash rtx && source <(rtx activate zsh)
fi
