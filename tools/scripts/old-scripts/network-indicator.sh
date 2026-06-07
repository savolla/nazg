#!/bin/bash
CONNECTED_ACCESS_POINT=$(iwgetid -r)

if [[ -z "$CONNECTED_ACCESS_POINT" ]]; then
    echo "󰖪 Not Connected"
else
    echo "󰖩 $CONNECTED_ACCESS_POINT"
fi
