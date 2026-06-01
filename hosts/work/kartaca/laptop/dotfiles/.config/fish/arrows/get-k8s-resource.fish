#!/usr/bin/env fish

function __kgr -d "get resource #k8s :kgr"
    set resource (kubectl api-resources --verbs=list -o name | fzf --prompt "resource: " || return 1)
    set name (kubectl get $resource -A -o json | jq -r '.items[].metadata.name' | fzf --prompt "name: " || return 1)
    set namespace (kubectl get $resource -A --field-selector metadata.name=$name -o jsonpath='{.items[0].metadata.namespace}' 2>/dev/null)

    if test -n "$namespace"
        echo "kubectl get -n $namespace $resource/$name -o yaml"
    else
        echo "kubectl get $resource/$name -o yaml | bat -l yaml"
    end
end
abbr -a kgr --function __kgr
