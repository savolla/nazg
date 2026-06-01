#!/usr/bin/env fish
function __wpd -d "watch pods of deployment #k8s :wpd"
    set service (kubectl get deploy -A -o json | jq -r '.items[].metadata.name' | fzf --prompt "deployment: " || return 1)
    echo "watch -t -n3 \"kubecolor get pods --force-colors | grep $service\""
end
abbr -a wpd --function __wpd
