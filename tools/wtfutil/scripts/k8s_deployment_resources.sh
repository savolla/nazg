#!/usr/bin/env bash

K8S_CONTEXT=$1
NAMESPACE=${2:-default}

CYAN=$'\033[36m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
NC=$'\033[0m'

OUTPUT=$(kubectl get deploy --context "$K8S_CONTEXT" -n "$NAMESPACE" -o json 2>/dev/null | jq -r '
  .items[] |
  .metadata.name as $name |
  (.status.readyReplicas // 0) as $ready |
  (.spec.replicas // 0) as $desired |
  .spec.template.spec.containers[0].resources.requests as $req |
  ($req.cpu // "N/A") as $cpu |
  ($req.memory // "N/A") as $mem |
  "\($name)\t\($ready)/\($desired)\t\($cpu)\t\($mem)"
' | awk -v cyan="$CYAN" -v green="$GREEN" -v yellow="$YELLOW" -v nc="$NC" '
{
  name=$1; reps=$2; cpu=$3; mem=$4
  split(reps, r, "/")
  rep_color=green
  if (r[1] != r[2] || r[2] == 0) { rep_color=yellow }
  printf "%-32s %s%-10s%s %-8s %-10s\n", name, rep_color, reps, nc, cpu, mem
}')

if [ -z "$OUTPUT" ]; then
  echo "${YELLOW}No deployments found in namespace: ${NAMESPACE}${NC}"
else
  printf "${CYAN}%-32s %-10s %-8s %-10s${NC}\n" "DEPLOYMENT" "REPLICAS" "CPU" "RAM"
  echo "$OUTPUT"
fi
