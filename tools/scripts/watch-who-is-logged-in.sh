#!/bin/bash

CURRENT_USER=$(whoami)
WATCH_PERIOD=3s

while true; do
    logged_in_users=$(who | awk '{print $1}' | sort | uniq)

    for user in $logged_in_users; do
        if [[ "$user" != "$CURRENT_USER" ]]; then
            notify-send -u critical "Security Alert" "User '$user' is logged in on $(date) !"
        fi
    done

    sleep $WATCH_PERIOD
done
