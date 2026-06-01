#!/usr/bin/env fish

function __klr -d "get logs #k8s :klr"
    set resource (kubectl api-resources --verbs=list -o name | fzf --prompt "resource: " || return 1)
    set name (kubectl get $resource -A -o json | jq -r '.items[].metadata.name' | fzf --prompt "name: " || return 1)
    set namespace (kubectl get $resource -A --field-selector metadata.name=$name -o jsonpath='{.items[0].metadata.namespace}' 2>/dev/null)

    if test -n "$namespace"
        echo "kubectl logs -f -n $namespace $resource/$name"
    else
        echo "kubectl logs -f $resource/$name"
    end
end
abbr -a klr --function __klr
