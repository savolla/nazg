#!/usr/bin/env bash
cd ~/.scripts || exit
PERIOD=0.5 # hours
DELAY=$(echo "3600*$PERIOD" | bc)

# update github, my website and other things periodically
while true; do
        ./update-repos.sh   # update all github repos
        # ./update-blog.sh    # update my blog
        echo -e "LOG: now waiting for some time.."
        sleep "$DELAY"
done
