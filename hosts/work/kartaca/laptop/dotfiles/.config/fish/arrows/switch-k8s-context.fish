#!/usr/bin/env fish

function __ksc -d "switch context #k8s :ksc | change context #k8s :ksc "
    set context (kubectl config get-contexts -o name | fzf --prompt='context: ' || return 1)
    echo "kubectl config use-context $context"
end
abbr -a ksc --function __ksc
