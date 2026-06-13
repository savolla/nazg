#!/usr/bin/env bash

K8S_CONTEXT=$1

RED=$'\033[31m'
YELLOW=$'\033[33m'
GREEN=$'\033[32m'
NC=$'\033[0m'

OUTPUT=$(kubectl get pods --context "$K8S_CONTEXT" -o json 2>/dev/null \
| jq -r '
  .items[]
  | .metadata.name as $pod
  | [
      (.status.containerStatuses[]?.state.waiting.reason),
      (.status.containerStatuses[]?.state.terminated.reason),
      .status.phase
    ]
  | flatten
  | map(select(. != null))
  | unique
  | . as $states
  | (
      $states
      | map(select(
          . == "CrashLoopBackOff" or
          . == "ImagePullBackOff" or
          . == "ErrImagePull" or
          . == "OOMKilled" or
          . == "Error"
        ))[0] //
      $states
      | map(select(. == "Pending" or . == "ContainerCreating"))[0]
    ) as $final_state
  | select($final_state != null)
  | "\($pod)\t\($final_state)"
' \
| awk -v red="$RED" -v yellow="$YELLOW" -v nc="$NC" '
  {
    pod=$1; state=$2
    color=yellow
    if (state ~ /CrashLoopBackOff|ImagePullBackOff|ErrImagePull|OOMKilled|Error/) {
      color=red
    }
    printf "%-35s %s%-20s%s\n", pod, color, state, nc
  }')

if [ -z "$OUTPUT" ]; then
  echo "${GREEN}All Good${NC}" | figlet
else
  echo "$OUTPUT"
fi
