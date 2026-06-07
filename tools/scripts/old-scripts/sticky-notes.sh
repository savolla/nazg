#!/usr/bin/env bash
set -euo pipefail

BASHRC_FILE="/home/savolla/.bashrc"
TMP_FILE_NAME="savolla-sticky-note.txt"
NOTE_TEXT=$(echo -e | dmenu -i -p "note:" -fn "Input" -y 540)

sed "2s/^/echo -e \"o $NOTE_TEXT\"\n/" $BASHRC_FILE > /tmp/$TMP_FILE_NAME
cat /tmp/$TMP_FILE_NAME > $BASHRC_FILE # transfer contents
