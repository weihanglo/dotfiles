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
    USAGE="Usage: bm [add|go|rm|ls] [bookmark]"

    if  [ -z ${BOOKMARKPATH} ] ; then
        echo "Error: environment variable 'BOOKMARKPATH' not found."
        return 1
    fi

    case $1 in

        a|add) shift
            mkdir -p "$BOOKMARKPATH" && ln -s "$(pwd)" "$BOOKMARKPATH/$1"
            ;;

        g|go) shift
            cd -P "$BOOKMARKPATH/$1" 2>/dev/null || echo "No such bookmark: $1"
            ;;

        rm) shift
            rm -i "$BOOKMARKPATH/$1" || echo "No such bookmark: $1"
            ;;

        ls|list)
            ls -l $BOOKMARKPATH | awk 'NR > 1 { print $9, "->", $11}'
            ;;

        *) echo "$USAGE"
            ;;
    esac
}
