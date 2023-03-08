#!/usr/bin/env bash

#--------------------------------------#
#  .bashrc for GNU bash, version 5.0   #
#            by Weihang Lo             #
#              Jun. 2021               #
#--------------------------------------#

# Default shell to bash
export SHELL=bash
# History settings (prepare earlily to avoid history corrupttion)
export HISTSIZE=
export HISTFILESIZE=
export HISTCONTROL="erasedups:ignoreboth"
export HISTIGNORE="&:[ ]*:exit:ls*:cd*:git*:tig*:nvim"
export PROMPT_COMMAND='history -a'

# ------------------------------------------------------------------------------
# Run for login shell.
# ------------------------------------------------------------------------------

shopt -q login_shell
if [[ $? -eq 0 ]]; then
    # LESS pager. More power.
    export LESS=isFMRX
    # EDITOR and VISUAL
    export VISUAL=nvim EDITOR=nvim
    # Set locale
    export LC_ALL=en_US.UTF-8

    # Ripgrep config
    export RIPGREP_CONFIG_PATH="$HOME/.config/ripgreprc"
    # Additional PATHs
    export PATH="$HOME/.local/bin:$PATH"
    export FZF_DEFAULT_COMMAND='rg --files --smart-case'
    # Rust
    export PATH="$HOME/.cargo/bin:$PATH"

    # Load `rtx` once and for all. A replacement for
    # - go
    # - nvm (fnm)
    # - opam
    # - pyenv
    # - rbenv
    hash rtx && source <(rtx activate bash)
fi

# ------------------------------------------------------------------------------
# Load only for interative shell.
# ------------------------------------------------------------------------------

if [[ $- == *i* ]]; then
    alias cat='bat'
    alias ll='exa -lhgF --git'
    alias ls='exa'
    alias ipy='ipython'
    alias ports='lsof -PiTCP -sTCP:LISTEN'
    alias tree='exa -TF --group-directories-first'
    alias k='kubectl'
    # Customizable prompt
    eval "$(starship init bash)"
    # A smarter cd command
    hash zoxide && eval "$(zoxide init bash)"

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

[ -f ~/.fzf.bash ] && source ~/.fzf.bash
