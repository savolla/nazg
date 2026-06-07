#!/bin/bash
LOOP_WAIT_TIME=10 # seconds
# KEYBOARD_MAC_ID="DC:2C:26:00:4D:E6"
# EARBUDS_MAC_ID="74:45:CE:31:EF:4C"

while true; do
    ### BLUETOOTH MONITORING
    # check keyboard connection

    # KEYBOARD_CONNECTION=$(bluetoothctl devices Connected | grep "$KEYBOARD_MAC_ID")
    # EARBUDS_CONNECTION=$(bluetoothctl devices Connected | grep "$EARBUDS_MAC_ID")

    # if [[ ! $KEYBOARD_CONNECTION ]]; then
    #     bluetoothctl connect $KEYBOARD_MAC_ID
    #     # notify-send "Keychron K3 is connected 󰌌"
    # fi

    # if [[ ! $EARBUDS_CONNECTION ]]; then
    #     bluetoothctl connect $EARBUDS_MAC_ID
    #     # notify-send "Sony Earbuds are connected 󱡏"
    # fi

    ### KEYBOARD SETTINGS REFRESHER
    xset r rate 180 60
    setxkbmap -option caps:swapescape

    sleep $LOOP_WAIT_TIME
done
