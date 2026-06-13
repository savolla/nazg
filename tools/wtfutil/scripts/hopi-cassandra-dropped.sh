#!/usr/bin/env bash

CASS_NODE=$1
JMX_MONITORING_USER=$2
JMX_MONITORING_PASS=$3

CYAN=$'\033[36m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RED=$'\033[31m'
NC=$'\033[0m'

# Fetch thread pool stats
TPSTATS=$(ssh -q "$CASS_NODE" "nodetool -h localhost -u $JMX_MONITORING_USER -pw $JMX_MONITORING_PASS tpstats 2>/dev/null")

if [ -z "$TPSTATS" ]; then exit 1; fi

printf "${CYAN}%-20s %-10s${NC}\n" "MESSAGE TYPE" "DROPPED"

# Parse tpstats for dropped messages
DROPPED=$(echo "$TPSTATS" | awk -v red="$RED" -v nc="$NC" '
BEGIN { found=0 }
# Look for the section that tracks dropped messages
/Message type/ { in_dropped=1; next }
in_dropped == 1 && NF >= 2 {
  msg_type=$1
  dropped_count=$2

  # Only print if drops > 0 and it looks like a number
  if (dropped_count ~ /^[0-9]+$/ && dropped_count > 0) {
    printf "%-20s %s%-10s%s\n", msg_type, red, dropped_count, nc
    found=1
  }
}
END {
  if (found == 0) print "ALL GOOD"
}' )

if [[ "$DROPPED" == "ALL GOOD" ]]; then
  echo -e "${GREEN}No dropped messages. Node is keeping up.${NC}"
else
  echo "$DROPPED"
fi
