#!/usr/bin/env bash

# Accept context as the first argument
K8S_CONTEXT=$1

RED=$'\033[31m'
YELLOW=$'\033[33m'
GREEN=$'\033[32m'
NC=$'\033[0m'

OUTPUT=$(kubectl get pods --context "$K8S_CONTEXT" --all-namespaces -o json 2>/dev/null \
  | jq -r '
    .items[]
    | .metadata.name as $pod
    | .status.containerStatuses[]?
    | select(.restartCount > 0)
    | "\($pod) \(.lastState.terminated.reason // "Unknown") \(.restartCount)"
  ' \
  | sort -k3 -nr \
  | awk -v red="$RED" -v yellow="$YELLOW" -v nc="$NC" '
  {
    pod=$1; reason=$2; count=$3
    color=yellow
    if (count > 5) { color=red }
    printf "%-45s %-14s %s%-5s%s\n", pod, reason, color, count, nc
  }')

if [ -z "$OUTPUT" ]; then
  echo "${GREEN}No restarted pods in context: ${K8S_CONTEXT}${NC}"
else
  echo "$OUTPUT"
fi
