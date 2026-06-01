#!/usr/bin/env fish

function __cat -d "cat file #linux"
    set file (find . -maxdepth 1 -type f | fzf --prompt "file: " || return 1)
    echo "bat $file"
end
abbr -a cat --function __cat
