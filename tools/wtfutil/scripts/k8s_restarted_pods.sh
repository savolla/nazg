#!/usr/bin/env bash

K8S_CONTEXT=$1
source "$(dirname "$0")/k8s-context-aware-notification-helper.sh"

RED=$'\033[31m'
YELLOW=$'\033[33m'
GREEN=$'\033[32m'
NC=$'\033[0m'

# Thresholds
CRITICAL_RESTARTS=5   # > this → critical notification
WARNING_RESTARTS=0    # > this → warning notification

# Raw data: "pod reason count" sorted by count desc
OUTPUT=$(kubectl get pods --context "$K8S_CONTEXT" --all-namespaces -o json 2>/dev/null \
  | jq -r '
    .items[]
    | .metadata.name as $pod
    | .status.containerStatuses[]?
    | select(.restartCount > 0)
    | "\($pod) \(.lastState.terminated.reason // "Unknown") \(.restartCount)"
  ' \
  | sort -k3 -nr)

# --- Notification logic ---
if [ -n "$OUTPUT" ]; then
  CRITICAL_PODS=$(echo "$OUTPUT" | awk -v t="$CRITICAL_RESTARTS" '$3 > t' || true)
  WARNING_PODS=$(echo "$OUTPUT"  | awk -v t="$CRITICAL_RESTARTS" '$3 <= t' || true)

  CRITICAL_COUNT=$(echo "$CRITICAL_PODS" | grep -c . || true)
  WARNING_COUNT=$(echo "$WARNING_PODS"   | grep -c . || true)

  CACHE_DIR="/tmp/k8s-restart-monitor"
  mkdir -p "$CACHE_DIR"
  CACHE="${CACHE_DIR}/${K8S_CONTEXT}.cache"
  CURRENT_HASH=$(echo "$OUTPUT" | md5sum)
  LAST_HASH=$(cat "$CACHE" 2>/dev/null)

  if [ "$CURRENT_HASH" != "$LAST_HASH" ]; then
    echo "$CURRENT_HASH" > "$CACHE"

    build_body() {
      local pods="$1" max=5 count=0 body=""
      while read -r pod reason restarts; do
        body+="• $pod  [$reason × $restarts]\n"
        (( ++count >= max )) && { body+="  …and more\n"; break; }
      done <<< "$pods"
      printf '%s' "$body"
    }

    if [ -n "$CRITICAL_PODS" ] && [ "$CRITICAL_COUNT" -gt 0 ]; then
        BODY=$(build_body "$CRITICAL_PODS")
        k8s_notify --urgency=critical --icon=dialog-error \
            "K8s HIGH POD RESTARTS — $K8S_CONTEXT" \
            "${CRITICAL_COUNT} pod(s) with >${CRITICAL_RESTARTS} restarts:\n${BODY}"
    fi

    if [ -n "$WARNING_PODS" ] && [ "$WARNING_COUNT" -gt 0 ]; then
        BODY=$(build_body "$WARNING_PODS")
        k8s_notify --urgency=normal --icon=dialog-warning \
            "K8s POD RESTARTS — $K8S_CONTEXT" \
            "${WARNING_COUNT} pod(s) with restarts:\n${BODY}"
    fi
  fi
fi

# --- Terminal output (unchanged behaviour) ---
COLORED=$(echo "$OUTPUT" | awk -v red="$RED" -v yellow="$YELLOW" -v nc="$NC" '
  NF {
    pod=$1; reason=$2; count=$3
    color=yellow
    if (count > 5) { color=red }
    printf "%-45s %-14s %s%-5s%s\n", pod, reason, color, count, nc
  }')

if [ -z "$OUTPUT" ]; then
  echo "${GREEN}No restarted pods in context: ${K8S_CONTEXT}${NC}"
else
  echo "$COLORED"
fi
