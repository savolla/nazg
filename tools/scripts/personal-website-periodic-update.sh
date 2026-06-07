#!/usr/bin/env bash

WEBSITE_PATH="${HOME}/project/repos/savolla.github.io"
# Infinite loop
while true; do

    cd "${WEBSITE_PATH}" || exit 1

    # Run python script inside nix-shell
    nix-shell --run "python ./org2tid.py"

    # Stage changes
    git add -A

    # Commit only if there are changes
    if ! git diff --cached --quiet; then
        git commit -m "automatic website update: $(date +%Y.%m.%d_%H:%M)"
        git push
    else
        echo "No changes to commit."
    fi

    # Wait 1 hour
    sleep 1h
done
