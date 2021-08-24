#!/usr/bin/env bash

if ! pgrep -f "Chrome"
then
    open -na "Google Chrome"
else
    osascript -e 'tell application "Google Chrome" to make new window'
fi
