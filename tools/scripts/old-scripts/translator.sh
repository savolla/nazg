#!/bin/bash

UNKNOWN_WORDS_CONTAINER="$HOME/txt/wisdom/unknown english words.org"
PHRASE=$(xsel | grep -v "No newline at end")
MEANING=$(trans --brief :tr "$PHRASE")
notify-send "$PHRASE : $MEANING"
WORD_COUNT=$(echo "$PHRASE" | wc -w)
IN_LIST=$(grep "$PHRASE" "$UNKNOWN_WORDS_CONTAINER")

if [ "$WORD_COUNT" -eq 1 ]; then
    if [ ! "$IN_LIST" ]; then
        echo "$PHRASE, $MEANING" >> "$UNKNOWN_WORDS_CONTAINER"
    fi
fi
