# @author: savolla
# @description: continues the process

#!/usr/bin/env bash
set -euo pipefail
PROCESS_ID=$(ps aux | grep -i $1 | grep -v grep | awk '{ print $2 }')
kill -CONT $PROCESS_ID
if [[ $? -eq 0 ]]; then
    notify-send -u normal --icon="$(pwd)/icons/play.png" "Continues:" "$1"
else
    notify-send -u normal --icon="$(pwd)/icons/error.png" "Faled to Continue!" "$1"
fi
