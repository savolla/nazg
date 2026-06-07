#!/usr/bin/env bash

# This script outputs a blinking red dot if asciinema is recording

# Check if asciinema is running
if pgrep asciinema > /dev/null; then
    # Use a simple toggle based on seconds (1 sec on, 1 sec off)
    if (( $(date +%s) % 2 == 0 )); then
        echo -e " "
    else
        echo " "  # blank for "off" phase
    fi
else
    echo ""  # nothing if asciinema not running
fi

