#!/usr/bin/env fish

function __cd -d "interactive cd #linux"
    set dir (fd . --type d --hidden --follow 2>/dev/null | fzf --prompt "dir: " || return 1)
    echo "cd $dir"
end
abbr -a cdx --function __cd
