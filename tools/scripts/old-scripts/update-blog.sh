#!/usr/bin/env bash

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# @author : savolla
# @description: this script will automatically generate and update my website
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

BLOG_PATH="$HOME/project"
GITHUB_PAGES="$HOME/project/savolla.github.io"
COMMIT_MESSAGE=$(curl -s http://whatthecommit.com | perl -p0e '($_)=m{<p>(.+?)</p>}s')

# generate my blog
cd "$BLOG_PATH"
hugo -d "$GITHUB_PAGES"

# update my website
cd "$GITHUB_PAGES"
git add --all
git commit -m "$COMMIT_MESSAGE"
git push -u origin master
