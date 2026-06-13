#!/usr/bin/env bash

K8S_CONTEXT=$1

RED=$'\033[31m'
YELLOW=$'\033[33m'
GREEN=$'\033[32m'
CYAN=$'\033[36m'
NC=$'\033[0m'

echo "${CYAN}FAILED JOBS${NC}"
FAILED=$(kubectl get jobs --context "$K8S_CONTEXT" -A -o json | jq -r '.items[] | select((.status.failed // 0) > 0) | "\(.metadata.namespace)\t\(.metadata.name)\tfailed=\(.status.failed)"')
if [ -z "$FAILED" ]; then echo "${GREEN}none${NC}"; else echo "$FAILED"; fi
echo ""

echo "${CYAN}RUNNING JOBS${NC}"
RUNNING=$(kubectl get jobs --context "$K8S_CONTEXT" -A -o json | jq -r '.items[] | select((.status.active // 0) > 0) | "\(.metadata.namespace)\t\(.metadata.name)\tactive=\(.status.active)"')
if [ -z "$RUNNING" ]; then echo "${GREEN}none${NC}"; else echo "$RUNNING"; fi
echo ""

echo "${CYAN}SUSPENDED CRONJOBS${NC}"
CRONS=$(kubectl get cronjobs --context "$K8S_CONTEXT" -A -o json | jq -r '.items[] | select(.spec.suspend == true) | "\(.metadata.namespace)\t\(.metadata.name)"')
if [ -z "$CRONS" ]; then echo "${GREEN}none${NC}"; else echo "$CRONS"; fi
echo ""

echo "${CYAN}NEVER EXECUTED${NC}"
NEVER=$(kubectl get cronjobs --context "$K8S_CONTEXT" -A -o json | jq -r '.items[] | select(.status.lastScheduleTime == null) | "\(.metadata.namespace)\t\(.metadata.name)"')
if [ -z "$NEVER" ]; then echo "${GREEN}none${NC}"; else echo "$NEVER"; fi
echo ""

echo "${CYAN}RECENT FAILED PODS${NC}"
kubectl get pods --context "$K8S_CONTEXT" -A --field-selector=status.phase=Failed --sort-by=.metadata.creationTimestamp 2>/dev/null | tail -5
