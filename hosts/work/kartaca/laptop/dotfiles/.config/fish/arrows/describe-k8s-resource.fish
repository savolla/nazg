#!/usr/bin/env fish

function __kdr -d "describe resource #k8s :kdr"
    set resource (kubectl api-resources --verbs=list -o name | fzf --prompt "resource: " || return 1)
    set name (kubectl get $resource -A -o json | jq -r '.items[].metadata.name' | fzf --prompt "name: " || return 1)
    set namespace (kubectl get $resource -A --field-selector metadata.name=$name -o jsonpath='{.items[0].metadata.namespace}' 2>/dev/null)

    if test -n "$namespace"
        echo "kubectl describe -n $namespace $resource/$name"
    else
        echo "kubectl describe $resource/$name"
    end
end
abbr -a kdr --function __kdr
