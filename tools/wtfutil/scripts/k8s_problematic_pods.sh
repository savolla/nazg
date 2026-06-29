#!/usr/bin/env bash

K8S_CONTEXT=$1
source "$(dirname "$0")/k8s-context-aware-notification-helper.sh"

RED=$'\033[31m'
YELLOW=$'\033[33m'
GREEN=$'\033[32m'
NC=$'\033[0m'

# Urgency levels for notify-send: low, normal, critical
CRITICAL_STATES="CrashLoopBackOff|ImagePullBackOff|ErrImagePull|OOMKilled|Error"
WARNING_STATES="Pending|ContainerCreating"

# Collect all problematic pods with their states
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
')

# --- Notification logic ---
if [ -n "$OUTPUT" ]; then
  # Separate critical vs warning pods
  CRITICAL_PODS=$(echo "$OUTPUT" | grep -E "$CRITICAL_STATES" || true)
  WARNING_PODS=$(echo "$OUTPUT"  | grep -E "$WARNING_STATES"  || true)

  CRITICAL_COUNT=$(echo "$CRITICAL_PODS" | grep -c . || true)
  WARNING_COUNT=$(echo "$WARNING_PODS"   | grep -c . || true)

  # Build a compact summary body (max ~5 lines to keep the notification readable)
  build_body() {
    local pods="$1" max=5 count=0 body=""
    while IFS=$'\t' read -r pod state; do
      body+="• $pod  [$state]\n"
      (( ++count >= max )) && { body+="  …and more\n"; break; }
    done <<< "$pods"
    printf '%s' "$body"
  }

  if [ -n "$CRITICAL_PODS" ] && [ "$CRITICAL_COUNT" -gt 0 ]; then
    BODY=$(build_body "$CRITICAL_PODS")
    k8s_notify --urgency=critical --icon=dialog-error \
      "K8S PROBLEMATIC PODS — $K8S_CONTEXT" \
      "${CRITICAL_COUNT} pod(s) in critical state:\n${BODY}"
  fi

  if [ -n "$WARNING_PODS" ] && [ "$WARNING_COUNT" -gt 0 ]; then
    BODY=$(build_body "$WARNING_PODS")
    k8s_notify --urgency=normal --icon=dialog-warning \
      "K8S PROBLEMATIC PODS — $K8S_CONTEXT" \
      "${WARNING_COUNT} pod(s) in warning state:\n${BODY}"
  fi
fi

# --- Terminal output (unchanged behaviour) ---
COLORED=$(echo "$OUTPUT" | awk -v red="$RED" -v yellow="$YELLOW" -v nc="$NC" '
  NF {
    pod=$1; state=$2
    color=yellow
    if (state ~ /CrashLoopBackOff|ImagePullBackOff|ErrImagePull|OOMKilled|Error/) {
      color=red
    }
    printf "%-35s %s%-20s%s\n", pod, color, state, nc
  }')

if [ -z "$OUTPUT" ]; then
  echo "All clear"
else
  echo "$COLORED"
fi
