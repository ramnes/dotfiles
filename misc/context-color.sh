#!/bin/bash
#
# context-color
# Copyright (C) 2018 Guillaume Gelin
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.

readonly PROGNAME=$(basename $0)
readonly DEFAULT_CONTEXT="whoami; hostname"

__context_color_usage() {
    cat <<- EOF
usage: $PROGNAME [OPTIONS] [CONTEXT]

Print a color sequence based on different context informations.
The default context uses current user and hostname and prints a foreground
color sequence.

OPTIONS:
    --help, -h              Print this help.
    --background, -b        Use a background sequence rather than foreground.

    --context <command>, -c <command>
                            Define the context command that must be used to
                            define the color.
    --if <regexp> --then <color>
                            If the regexp is found in the output of the context
                            command, override the color to the given one.
                            For example, this would force root user to red:
                                --if ".*root.*" --then "9"
                            The color number must be included inside the number
                            of colors handled by the terminal, or it will be
                            ignored.

CONTEXT:
    A command line that will be executed in that order to define the current
    context, which in turn will define what color to use.
    The default context is equivalent to: $PROGNAME -c "whoami; hostname"
EOF
}

__context_color_count() {
    infocmp -1 | sed -n -e "s/^\t*colors#\([0-9][0-9]*\),.*/\1/p"
}

__context_color_hash() {
    eval "$CONTEXT" | sum
}

__context_color_number_from_hash() {
    awk -v count=$(__context_color_count) \
        'count>1 {print 1 + ($1 % (count - 1))}'
}

__context_color_number() {
    __context_color_hash | __context_color_number_from_hash
}

__context_color_sequence() {
    local capname="setaf"

    if [ $BACKGROUND ]
    then
        capname="setab"
    fi

    echo "$(tput $capname $(__context_color_number))"
}

__context_color() {
    if [[ ! "$CONTEXT" ]]
    then
        CONTEXT="$DEFAULT_CONTEXT"
    fi

    local arg
    for arg
    do
        local delim=""
        case "$arg" in
            --help)
                args="${args}-h "
                ;;
            --background)
                args="${args}-b "
                ;;
            --context)
                args="${args}-c "
                ;;
            *)
                args="$args $arg"
                ;;
        esac
    done

    eval set -- $args

    while getopts "hbc:" OPTION
    do
         case $OPTION in
         h)
             __context_color_usage
             exit 0
             ;;
         b)
             readonly BACKGROUND=1
             ;;
         c)
             CONTEXT="$OPTARG"
             ;;
         esac
    done

    echo -n "$(__context_color_sequence)"
    return 0
}

__context_color "$@"
