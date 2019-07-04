#!/bin/bash
if [ -f ~/.bashrc ]; then
    # shellcheck disable=SC1090
    . ~/.bashrc
fi

if [[ $(tty) == /dev/tty1 && ! $DISPLAY ]]; then
    exec xinit -- -ardelay 200 -arinterval 20
fi
