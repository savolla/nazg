#!/bin/bash
WALLPAPERS_DIR="/home/savolla/resource/images/wallpapers"
while true; do
    # Shuffle the list of wallpapers and select one randomly
    wallpaper=$(ls "$WALLPAPERS_DIR" | shuf -n 1)
    feh --bg-scale "$WALLPAPERS_DIR/$wallpaper"
    sleep 1h
done
