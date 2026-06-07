#!/bin/sh

MUSIC_DIR="$HOME/resource/music"
TEMP_COVER="/tmp/mpd_current_cover.jpg"

while true; do
    # Wait for player event
    mpc idle player >/dev/null 2>&1

    # Small delay so MPD updates metadata
    sleep 0.1

    # Fetch metadata
    INFO=$(mpc current -f "%artist%
%title%
%album%
%file%")

    # Reset variables
    ARTIST=""
    TITLE=""
    ALBUM=""
    FILE=""

    if [ -n "$INFO" ]; then
        ARTIST=$(printf '%s\n' "$INFO" | sed -n '1p')
        TITLE=$(printf '%s\n' "$INFO" | sed -n '2p')
        ALBUM=$(printf '%s\n' "$INFO" | sed -n '3p')
        FILE=$(printf '%s\n' "$INFO" | sed -n '4p')
    else
        FILE=$(mpc current -f "%file%")
        TITLE=$(mpc current -f "%title%")
        ARTIST=$(mpc current -f "%artist%")
        ALBUM=$(mpc current -f "%album%")
    fi

    # Fallback title from filename
    if [ -z "$TITLE" ] && [ -n "$FILE" ]; then
        TITLE=$(basename "$FILE")
    fi

    # Nothing playing
    if [ -z "$FILE" ]; then
        echo "No song playing or metadata missing."
        continue
    fi

    COVER_ICON="$TEMP_COVER"

    # Remove old cover
    rm -f "$TEMP_COVER"

    # Extract embedded cover art
    ffmpeg -y -loglevel quiet \
        -i "$MUSIC_DIR/$FILE" \
        -an -vcodec copy "$TEMP_COVER" >/dev/null 2>&1

    # Fallback to local cover.jpg
    if [ ! -s "$TEMP_COVER" ]; then
        ALBUM_DIR=$(dirname "$MUSIC_DIR/$FILE")

        if [ -f "$ALBUM_DIR/cover.jpg" ]; then
            cp "$ALBUM_DIR/cover.jpg" "$TEMP_COVER"
        else
            COVER_ICON="audio-x-generic"
        fi
    fi

    BODY="  <b>${ARTIST:-Unknown}</b>\n󰀥  ${ALBUM:-Unknown}"

    # Send notification
    dunstify \
        -r 27071 \
        -u low \
        -t 10000 \
        -h string:x-dunst-stack-tag:music \
        -i "$COVER_ICON" \
        "$TITLE" \
        "$BODY"
done
