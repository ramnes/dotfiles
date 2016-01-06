#!/usr/bin/env python3
"""xev output data parser to get mouse polling rate.

Usage:
    $ chmod a+x mouserate
    $ xev | mouserate
"""
import sys
import re

previous = 0
time_re = re.compile('time (\d+)')

while True:
    line = sys.stdin.readline()
    match = time_re.search(line)
    if match:
        time = int(match.group(1))
        if previous:
            try:
                rate = round(1000 / (time - previous), 2)
                print("{:.2f}Hz".format(rate))
                sys.stdout.flush()
            except ZeroDivisionError:
                pass
        previous = time
