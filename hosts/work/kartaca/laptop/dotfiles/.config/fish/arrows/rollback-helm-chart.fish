#!/usr/bin/env fish
function __hrb -d "rollback helm chart #k8s #helm :hrb | revert helm chart #k8s #helm :hrb"
    set chart (helm list --no-headers | awk '{ print $1 }' | fzf --prompt "chart: " || return 1)
    set revision (helm history $chart | tac | grep -vi "revision" | awk '{ print $1, $7 }' | fzf --prompt "revision: " || return 1)
    set rev (echo $revision | awk '{ print $1 }')
    echo "helm rollback $chart $rev"
end
abbr -a hrb --function __hrb
