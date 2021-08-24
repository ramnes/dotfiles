#!/usr/bin/env bash

if ! pgrep -f "iTerm"
then
    open -na "iTerm"
else
    osascript -e 'tell application "iTerm2" to create window with default profile'
fi
