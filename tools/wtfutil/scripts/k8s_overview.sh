#!/usr/bin/env bash

K8S_CONTEXT=$1
CERT_HOST=$2

GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RED=$'\033[31m'
NC=$'\033[0m'

# Basic Cluster Stats
node_count=$(kubectl get nodes --context "$K8S_CONTEXT" --no-headers 2>/dev/null | wc -l)
deploy_count=$(kubectl get deploy --context "$K8S_CONTEXT" --no-headers 2>/dev/null | wc -l)
pod_count=$(kubectl get pod --context "$K8S_CONTEXT" --no-headers 2>/dev/null | wc -l)
service_count=$(kubectl get service --context "$K8S_CONTEXT" --no-headers 2>/dev/null | wc -l)

# K8S API Latency
START=$(date +%s%N)
kubectl get nodes --context "$K8S_CONTEXT" > /dev/null 2>&1
END=$(date +%s%N)

API_MS=$(( (END - START) / 1000000 ))

if [ "$API_MS" -lt 300 ]; then
  API_STATUS="${GREEN}${API_MS}ms OK${NC}"
elif [ "$API_MS" -lt 1000 ]; then
  API_STATUS="${YELLOW}${API_MS}ms SLOW${NC}"
else
  API_STATUS="${RED}${API_MS}ms BAD${NC}"
fi

# TLS Cert Expiry Check (Optional based on $2)
if [ -n "$CERT_HOST" ]; then
  # Get expiration in epoch time
  CERT_DAYS=$(
    echo | openssl s_client -servername "$CERT_HOST" -connect "$CERT_HOST:443" 2>/dev/null \
    | openssl x509 -noout -enddate 2>/dev/null \
    | cut -d= -f2 \
    | xargs -I{} date -d "{}" +%s 2>/dev/null
  )
  NOW=$(date +%s)

  if [ -n "$CERT_DAYS" ]; then
    DIFF=$(( (CERT_DAYS - NOW) / 86400 ))
    # Convert the epoch time into YYYY-MM-DD HH:MM
    EXACT_DATE=$(date -d "@$CERT_DAYS" +"%Y-%m-%d %H:%M" 2>/dev/null)

    if [ "$DIFF" -lt 14 ]; then CERT_STATUS="${RED}${DIFF}d [${EXACT_DATE}]${NC}"
    elif [ "$DIFF" -lt 30 ]; then CERT_STATUS="${YELLOW}${DIFF}d [${EXACT_DATE}]${NC}"
    else CERT_STATUS="${GREEN}${DIFF}d [${EXACT_DATE}]${NC}"
    fi
  else
    CERT_STATUS="${RED}ERR${NC}"
  fi
else
  CERT_STATUS="N/A"
fi

# Server Version
k8s_server_version=$(
  kubectl get nodes --context "$K8S_CONTEXT" -o jsonpath='{range .items[*]}{.status.nodeInfo.kubeletVersion}{"\n"}{end}' 2>/dev/null \
  | sort -u -V \
  | awk '{ v[NR] = $0 } END { if (NR == 1) print v[1]; else { printf "%s", v[1]; for (i = 2; i <= NR; i++) printf ", %s", v[i]; print " DIVERGED" } }'
)

# Output
{
  printf "nodes %s\n" "$node_count"
  printf "deployments %s\n" "$deploy_count"
  printf "pods %s\n" "$pod_count"
  printf "services %s\n" "$service_count"
  printf "k8s_version %s\n" "$k8s_server_version"
  printf "API %s\n" "$API_STATUS"
  if [ -n "$CERT_HOST" ]; then printf "SSL_expires_in: %s\n" "$CERT_STATUS"; fi
} | column -t
