#!/usr/bin/env bash

caffeinate -dimsu sh -c 'while sleep 5; ioreg -n Root -d1 | grep -q CGSSessionScreenIsLocked; do :; done' &
/usr/bin/python3 -c 'import ctypes; ctypes.CDLL("/System/Library/PrivateFrameworks/login.framework/login").SACLockScreenImmediate()'
