#!/usr/bin/env fish

function __kcc -d "get current context #k8s :kcc"
    set context (kubectl config current-context || return 1)
    echo "kubectl config current-context"
end
abbr -a kcc --function __kcc
