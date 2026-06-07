#!/usr/bin/env bash

set -x
TIMEOUT=1h
REPO_LIST=(
    "$HOME/project/publishing/savolla.github.io"
    "$HOME/project/scripts"
    "$HOME/project/environ"
)

while true; do
    for repo in "${REPO_LIST[@]}"; do
        cd "$repo" || { echo "Failed to cd into $repo"; continue; }

        if [ -n "$(git status --porcelain)" ]; then
            git add .
            git commit -m "auto: sync $(date "+%Y.%m.%d %H:%M")"
            git push || echo "Push failed for $repo"
        else
            echo "No changes in $repo"
        fi
    done

    # sync dotfiles
    git --git-dir="$HOME"/.dotfiles/ --work-tree="$HOME" add -u
    git --git-dir="$HOME"/.dotfiles/ --work-tree="$HOME" commit -m "auto: sync $(date "+%Y.%m.%d %H:%M")"
    git --git-dir="$HOME"/.dotfiles/ --work-tree="$HOME" push

    sleep "$TIMEOUT"
done
