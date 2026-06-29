#!/usr/bin/env bash

K8S_CONTEXT=$1
source "$(dirname "$0")/k8s-context-aware-notification-helper.sh"

CYAN=$'\033[36m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RED=$'\033[31m'
NC=$'\033[0m'

CACHE_DIR="/tmp/k8s-top-monitor"
mkdir -p "$CACHE_DIR"
CACHE_CPU="${CACHE_DIR}/${K8S_CONTEXT}_cpu.cache"
CACHE_MEM="${CACHE_DIR}/${K8S_CONTEXT}_mem.cache"

export POD_LIMITS=$(kubectl get pods --context "$K8S_CONTEXT" -o json 2>/dev/null | jq -r '
  .items[] |
  .metadata.name as $name |
  .spec.containers[0].resources.limits as $lim |
  "\($name) \($lim.cpu // "0") \($lim.memory // "0")"
')

TOP_STATS=$(kubectl top pods --context "$K8S_CONTEXT" --no-headers 2>/dev/null)

PROCESS_AWK='
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
  if (mode == "cpu") {
    u = cpu; sub(/m/, "", u); tot = l_cpu[pod]; disp_u = cpu; unit = "m"
  } else {
    u = mem; sub(/Mi/, "", u); tot = l_mem[pod]; disp_u = mem; unit = "Mi"
  }
  if (tot > 0) {
    pct_val = int((u / tot) * 100); pct = pct_val "%"; disp_tot = tot unit
  } else {
    pct_val = 0; pct = "N/A"; disp_tot = "N/A"
  }
  color = green
  if (pct != "N/A") {
    if (pct_val >= 85) color = red
    else if (pct_val >= 60) color = yellow
  }
  printf "%-38s %-8s %-8s %s%s%s\n", pod, disp_u, disp_tot, color, pct, nc
}'

# Raw awk for notification data (no colors, emits: pod usage limit pct_val)
RAW_AWK='
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
  if (mode == "cpu") {
    u = cpu; sub(/m/, "", u); tot = l_cpu[pod]; disp_u = cpu
  } else {
    u = mem; sub(/Mi/, "", u); tot = l_mem[pod]; disp_u = mem
  }
  pct_val = (tot > 0) ? int((u / tot) * 100) : 0
  printf "%s\t%s\t%d\n", pod, disp_u, pct_val
}'

# --- Notification helper ---
# Args: resource_label cache_file pod usage pct_val
notify_if_needed() {
  local label="$1" cache="$2" pod="$3" usage="$4" pct_val="$5"

  if (( pct_val < 60 )); then return; fi

  if (( pct_val >= 85 )); then
    URGENCY="critical"; ICON="dialog-error"; EMOJI="🔴"; TIER="CRITICAL"
  else
    URGENCY="normal";   ICON="dialog-warning"; EMOJI="🟡"; TIER="WARNING"
  fi

  PREV_LINE=$(grep -F "$pod" "$cache" 2>/dev/null || true)
  PREV_TIER=""
  if [ -n "$PREV_LINE" ]; then
    PREV_PCT=$(echo "$PREV_LINE" | awk -F'\t' '{print $3}')
    if   (( PREV_PCT >= 85 )); then PREV_TIER="CRITICAL"
    elif (( PREV_PCT >= 60 )); then PREV_TIER="WARNING"
    fi
  fi

  # Fire only on: new entry into top-5, or WARNING→CRITICAL escalation
  # if [ -z "$PREV_LINE" ] || \
  #    { [ "$PREV_TIER" = "WARNING" ] && [ "$TIER" = "CRITICAL" ]; }; then
  #   notify-send \
  #     --urgency="$URGENCY" \
  #     --icon="$ICON" \
  #     --app-name="k8s-monitor" \
  #     "${EMOJI} K8s TOP ${label} ${TIER} — $K8S_CONTEXT" \
  #     "${pod}\n${label}: ${usage}  (${pct_val}% of limit)"
  # fi
}

# --- Collect raw top-5 for each resource ---
RAW_CPU=$(echo "$TOP_STATS" | sort -k2 -nr | head -5 \
  | awk -v mode="cpu" "$RAW_AWK")

RAW_MEM=$(echo "$TOP_STATS" | sort -k3 -nr | head -5 \
  | awk -v mode="mem" "$RAW_AWK")

# --- Diff and notify ---
# while IFS=$'\t' read -r pod usage pct_val; do
#   [[ -z "$pod" ]] && continue
#   notify_if_needed "CPU" "$CACHE_CPU" "$pod" "$usage" "$pct_val"
# done <<< "$RAW_CPU"

# while IFS=$'\t' read -r pod usage pct_val; do
#   [[ -z "$pod" ]] && continue
#   notify_if_needed "MEM" "$CACHE_MEM" "$pod" "$usage" "$pct_val"
# done <<< "$RAW_MEM"

# Update caches
echo "$RAW_CPU" > "$CACHE_CPU"
echo "$RAW_MEM" > "$CACHE_MEM"

# --- Terminal output (unchanged behaviour) ---
echo "${CYAN}TOP CPU${NC}"
printf "${CYAN}%-38s %-8s %-8s %s${NC}\n" "POD NAME" "USAGE" "LIMIT" "PCT"
echo "$TOP_STATS" | sort -k2 -nr | head -5 \
  | awk -v mode="cpu" -v red="$RED" -v yellow="$YELLOW" -v green="$GREEN" -v nc="$NC" "$PROCESS_AWK"

echo ""

echo "${CYAN}TOP MEMORY${NC}"
printf "${CYAN}%-38s %-8s %-8s %s${NC}\n" "POD NAME" "USAGE" "LIMIT" "PCT"
echo "$TOP_STATS" | sort -k3 -nr | head -5 \
  | awk -v mode="mem" -v red="$RED" -v yellow="$YELLOW" -v green="$GREEN" -v nc="$NC" "$PROCESS_AWK"
