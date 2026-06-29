#!/usr/bin/env bash

K8S_CONTEXT=$1
source "$(dirname "$0")/k8s-context-aware-notification-helper.sh"

CYAN=$'\033[36m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RED=$'\033[31m'
NC=$'\033[0m'

CACHE_DIR="/tmp/k8s-resource-monitor"
mkdir -p "$CACHE_DIR"
CACHE="${CACHE_DIR}/${K8S_CONTEXT}.cache"

export POD_LIMITS=$(kubectl get pods --context "$K8S_CONTEXT" -o json 2>/dev/null | jq -r '
  .items[] |
  .metadata.name as $name |
  .spec.containers[0].resources.limits as $lim |
  "\($name) \($lim.cpu // "0") \($lim.memory // "0")"
')

TOP_STATS=$(kubectl top pods --context "$K8S_CONTEXT" --no-headers 2>/dev/null)

# --- Collect raw pressured pod data (no colors) for diffing + notifications ---
RAW=$(echo "$TOP_STATS" | awk '
BEGIN {
  split(ENVIRON["POD_LIMITS"], lines, "\n")
  for (i in lines) {
    split(lines[i], parts, " ")
    pod=parts[1]; c_lim=parts[2]; m_lim=parts[3]

    if (c_lim ~ /m$/) { sub(/m/, "", c_lim); l_cpu[pod] = c_lim }
    else if (c_lim > 0) { l_cpu[pod] = c_lim * 1000 }
    else { l_cpu[pod] = 0 }

    if (m_lim ~ /Mi$/) { sub(/Mi/, "", m_lim); l_mem[pod] = m_lim }
    else if (m_lim ~ /Gi$/) { sub(/Gi/, "", m_lim); l_mem[pod] = m_lim * 1024 }
    else if (m_lim ~ /Ki$/) { sub(/Ki/, "", m_lim); l_mem[pod] = m_lim / 1024 }
    else { l_mem[pod] = 0 }
  }
}
{
  pod=$1; cpu=$2; mem=$3

  u_c = cpu; sub(/m/, "", u_c); t_c = l_cpu[pod]; p_c = 0
  if (t_c > 0) p_c = int((u_c / t_c) * 100)

  u_m = mem; sub(/Mi/, "", u_m); t_m = l_mem[pod]; p_m = 0
  if (t_m > 0) p_m = int((u_m / t_m) * 100)

  if (p_c >= 85 || p_m >= 85) {
    severity = "WARNING"
    if (p_c >= 95 || p_m >= 95) severity = "CRITICAL"
    printf "%s\t%s\t%s\t%d\t%d\n", pod, cpu, mem, p_c, p_m
  }
}')

# --- Notification logic ---
if [ -n "$RAW" ]; then
  PREV_PODS=""
  [ -f "$CACHE" ] && PREV_PODS=$(<"$CACHE")

  while IFS=$'\t' read -r pod cpu mem p_c p_m; do
    [[ -z "$pod" ]] && continue

    # Determine severity
    if (( p_c >= 95 || p_m >= 95 )); then
      URGENCY="critical"
      ICON="dialog-error"
      EMOJI="🔴"
      LABEL="CRITICAL"
    else
      URGENCY="normal"
      ICON="dialog-warning"
      EMOJI="🟡"
      LABEL="WARNING"
    fi

    # Build per-resource breakdown
    BODY=""
    (( p_c >= 85 )) && BODY+="CPU: ${p_c}% of limit (${cpu})\n"
    (( p_m >= 85 )) && BODY+="RAM: ${p_m}% of limit (${mem})\n"

    # Only notify if this pod wasn't already in the pressured set at this severity
    PREV_LINE=$(echo "$PREV_PODS" | grep -F "$pod" || true)
    PREV_SEVERITY=""
    if [ -n "$PREV_LINE" ]; then
      PREV_P_C=$(echo "$PREV_LINE" | awk -F'\t' '{print $4}')
      PREV_P_M=$(echo "$PREV_LINE" | awk -F'\t' '{print $5}')
      if (( PREV_P_C >= 95 || PREV_P_M >= 95 )); then
        PREV_SEVERITY="CRITICAL"
      elif (( PREV_P_C >= 85 || PREV_P_M >= 85 )); then
        PREV_SEVERITY="WARNING"
      fi
    fi

    # Fire if: pod is new to the pressured set, or severity escalated
    # if [ -z "$PREV_LINE" ] || \
    #    { [ "$PREV_SEVERITY" = "WARNING" ] && [ "$LABEL" = "CRITICAL" ]; }; then
    #   notify-send \
    #     --urgency="$URGENCY" \
    #     --icon="$ICON" \
    #     --app-name="k8s-monitor" \
    #     "${EMOJI} K8s ${LABEL} — $K8S_CONTEXT" \
    #     "${pod}\n${BODY}"
    # fi

  done <<< "$RAW"

  echo "$RAW" > "$CACHE"
else
  # All clear — wipe cache so pods re-notify if pressure returns
  rm -f "$CACHE"
fi

# --- Terminal output (unchanged behaviour) ---
OUTPUT=$(echo "$TOP_STATS" | awk -v red="$RED" -v yellow="$YELLOW" -v nc="$NC" '
BEGIN {
  split(ENVIRON["POD_LIMITS"], lines, "\n")
  for (i in lines) {
    split(lines[i], parts, " ")
    pod=parts[1]; c_lim=parts[2]; m_lim=parts[3]

    if (c_lim ~ /m$/) { sub(/m/, "", c_lim); l_cpu[pod] = c_lim }
    else if (c_lim > 0) { l_cpu[pod] = c_lim * 1000 }
    else { l_cpu[pod] = 0 }

    if (m_lim ~ /Mi$/) { sub(/Mi/, "", m_lim); l_mem[pod] = m_lim }
    else if (m_lim ~ /Gi$/) { sub(/Gi/, "", m_lim); l_mem[pod] = m_lim * 1024 }
    else if (m_lim ~ /Ki$/) { sub(/Ki/, "", m_lim); l_mem[pod] = m_lim / 1024 }
    else { l_mem[pod] = 0 }
  }
}
{
  pod=$1; cpu=$2; mem=$3

  u_c = cpu; sub(/m/, "", u_c); t_c = l_cpu[pod]; p_c = 0
  if (t_c > 0) p_c = int((u_c / t_c) * 100)

  u_m = mem; sub(/Mi/, "", u_m); t_m = l_mem[pod]; p_m = 0
  if (t_m > 0) p_m = int((u_m / t_m) * 100)

  if (p_c >= 85 || p_m >= 85) {
    color = yellow
    if (p_c >= 95 || p_m >= 95) color = red

    issue = ""
    if (p_c >= 85) issue = issue "CPU: " p_c "%  "
    if (p_m >= 85) issue = issue "RAM: " p_m "%"

    if (length(pod) > 34) {
      pod = substr(pod, 1, 31) "..."
    }

    printf "%-35s %s%-12s%s %-8s %-8s\n", pod, color, issue, nc, cpu, mem
  }
}')

if [ -z "$OUTPUT" ]; then
  echo "${GREEN}✓ No pods are currently struggling (>85% limits)${NC}"
else
  printf "${CYAN}%-35s %-12s %-8s %-8s${NC}\n" "POD NAME" "BOTTLENECK" "CPU" "RAM"
  echo "$OUTPUT"
fi
