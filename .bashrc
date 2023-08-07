#!/usr/bin/env bash

#--------------------------------------#
#  .bashrc for GNU bash, version 5.0   #
#            by Weihang Lo             #
#              July 2023               #
#--------------------------------------#

# Default shell to bash
export SHELL=$(command -v bash)

# History settings (prepare earlily to avoid history corrupttion)
# Temporariliy superseded by atuin
#export HISTSIZE=
#export HISTFILESIZE=
#export HISTCONTROL="erasedups:ignoreboth"
#export HISTIGNORE="&:[ ]*:exit:ls*:cd*:git*:tig*:nvim"
#export PROMPT_COMMAND='history -a'

# ------------------------------------------------------------------------------
# Run for login shell.
# ------------------------------------------------------------------------------

shopt -q login_shell
if [[ $? -eq 0 ]]; then
    source "$HOME/.shenv"
    # Load `rtx` once and for all.
    hash rtx && source <(rtx activate bash --disable-up-arrow)
fi

# ------------------------------------------------------------------------------
# Load only for interative shell.
# ------------------------------------------------------------------------------

if [[ $- == *i* ]]; then
    source "$HOME/.shalias"
    # Customizable prompt
    eval "$(starship init bash)"
    # A smarter cd command
    hash zoxide && eval "$(zoxide init bash)"
    # A smarter history management
    hash atuin && eval "$(atuin init bash)"

    # Bash completion
    if [[ -n "$PS1" ]]; then
        if [[ $(uname) == "Darwin" ]]; then
            export BASH_COMPLETION_COMPAT_DIR="$(brew --prefix)/etc/bash_completion.d"
            [[ -f "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]] && \
            . "$(brew --prefix)/etc/profile.d/bash_completion.sh"
        else
            [[ -f /usr/share/bash-completion/bash_completion ]] && \
            . /usr/share/bash-completion/bash_completion
        fi
    fi
fi

# ------------------------------------------------------------------------------
# Commands that always run for all sessions go below.
# ------------------------------------------------------------------------------
