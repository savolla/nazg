#!/usr/bin/env bash

CURRENT_HOUR=$(date "+%T" | awk -F ":" '{ print $1 }')
HALF_OF_AN_HOUR=$((30*60))
MIDNIGHT_WALLPAPER="$USER/.scripts/"
while true
do
    if [[ "CURRENT_HOUR" -gt "6" ]] && [[ "CURRENT_HOUR" -lt "11" ]]
       feh --bg-fill
        sleep $HALF_OF_AN_HOUR
    fi
done
