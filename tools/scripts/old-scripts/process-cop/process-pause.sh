# @author: savolla
# @description: stops a process

#!/usr/bin/env bash
set -euo pipefail
PROCESS_ID=$(ps aux | grep -i $1 | grep -v grep | awk '{ print $2 }')
kill -STOP $PROCESS_ID
if [[ $? -eq 0 ]]; then
    notify-send -u critical --icon="$(pwd)/icons/stop.png" "Paused:" "$1"
else
    notify-send -u normal --icon="$(pwd)/icons/error.png" "Faled to Stop!" "$1"
fi
