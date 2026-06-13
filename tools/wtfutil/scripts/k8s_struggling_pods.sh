#!/usr/bin/env bash

K8S_CONTEXT=$1

CYAN=$'\033[36m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RED=$'\033[31m'
NC=$'\033[0m'

export POD_LIMITS=$(kubectl get pods --context "$K8S_CONTEXT" -o json 2>/dev/null | jq -r '
  .items[] |
  .metadata.name as $name |
  .spec.containers[0].resources.limits as $lim |
  "\($name) \($lim.cpu // "0") \($lim.memory // "0")"
')

TOP_STATS=$(kubectl top pods --context "$K8S_CONTEXT" --no-headers 2>/dev/null)

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
