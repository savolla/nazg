#!/bin/sh
export DISPLAY="${DISPLAY:-:0}"

if [ -f "$HOME/.xprofile" ]; then
  . "$HOME/.xprofile"
fi

exec dwm
