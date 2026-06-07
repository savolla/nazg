# ~/.xinitrc

if [ -f "$HOME/.xprofile" ]; then
    . "$HOME/.xprofile"
fi

exec dwm

