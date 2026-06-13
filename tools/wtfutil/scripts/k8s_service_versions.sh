#!/usr/bin/env bash

K8S_CONTEXT=$1
NAMESPACE=${2:-default}

for deploy in $(kubectl get --context "$K8S_CONTEXT" deploy -n "$NAMESPACE" -o jsonpath='{.items[*].metadata.name}'); do
  kubectl --context "$K8S_CONTEXT" get deploy "$deploy" -n "$NAMESPACE" -o yaml \
  | yq -r '.spec.template.spec.containers[] | "\(.name): \(.image | split(":")[-1])"'
done | sort | column -t
echo ""
