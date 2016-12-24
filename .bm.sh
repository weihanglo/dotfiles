#!/bin/sh

#--------------------------------------#
#           Bookmark Manager           #
#       for GNU bash, Version 4.3      #
#                                      #
#            by Weihang Lo             #
#            November 2016             #
#--------------------------------------#

# References:
# http://jeroenjanssens.com/2013/08/16/quickly-navigate-your-filesystem-from-the-command-line.html
# http://stackoverflow.com/questions/7374534/directory-bookmarking-for-bash

function bm() {
    local USAGE="Usage: bm [add|go|rm|ls] [bookmark ...]"

    if  [ -z ${BOOKMARKPATH} ] ; then
        echo "\e[31mError:\e[0m environment variable 'BOOKMARKPATH' not found."
        return 1
    fi

    case $1 in

        a|add) shift
            mkdir -p "$BOOKMARKPATH" && ln -is "$(pwd)" "$BOOKMARKPATH/$1"
            ;;

        g|go) shift
            [ -z $1 ] && echo -e "\e[31mError:\e[0m missing arg 'bookmark'" \
                && return 1
            cd -P "$BOOKMARKPATH/$1" 2>/dev/null || echo "No such bookmark: $1"
            ;;

        rm|remove) shift
            [ -z $1 ] && echo -e "\e[31mError:\e[0m missing arg 'bookmark'" \
                && return 1
            rm -i "$BOOKMARKPATH/$1" || echo "No such bookmark: $1"
            ;;

        mv|move) shift
            [ -z "$1$2" ] && \
                echo -e "\e[31mError:\e[0m missing arg 'bookmark'" && return 1
            mv -i "$BOOKMARKPATH/$1" "$BOOKMARKPATH/$2" || \
                echo "Rename bookmark failed: $1 -> $2"
            ;;

        ls|list)
            ls -lA $BOOKMARKPATH | grep "\->" | \
                awk 'NR > 0 { printf "%-20s -> %s\n", $9, $11}'
            ;;

        *)
            echo "$USAGE"
            ;;
    esac
}


# bash completion -----------------

__bm_completion() {
    local cur=${COMP_WORDS[COMP_CWORD]}
    local prev=${COMP_WORDS[COMP_CWORD-1]}

    case ${COMP_CWORD} in 
        1)
            COMPREPLY=($(compgen -W "add go rm mv ls" ${cur}))
            ;;

        2)
            case ${prev} in
                g|go|rm|remove|mv|move)
                    local words
                    words=$(find $BOOKMARKPATH -type l -exec basename {} ';')
                    COMPREPLY=($(compgen -W "$words" ${cur}))
                    ;;
            esac
            ;;
    esac
}

complete -F __bm_completion bm
