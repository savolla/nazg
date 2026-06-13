#!/usr/bin/env bash

CASS_NODE=$1
JMX_MONITORING_USER=$2
JMX_MONITORING_PASS=$3

CYAN=$'\033[36m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RED=$'\033[31m'
NC=$'\033[0m'

# Fetch uptime (from info) and cluster status in a single SSH call
OUTPUT=$(ssh -q "$CASS_NODE" "nodetool -h localhost -u $JMX_MONITORING_USER -pw $JMX_MONITORING_PASS info 2>/dev/null | grep '^Uptime'; nodetool -h localhost -u $JMX_MONITORING_USER -pw $JMX_MONITORING_PASS status 2>/dev/null")

if [ -z "$OUTPUT" ]; then
  echo -e "${RED}Failed to connect to Cassandra via $CASS_NODE${NC}"
  exit 1
fi

echo -e "${CYAN}NODE STATUS TALLY${NC}"

echo "$OUTPUT" | awk -v cyan="$CYAN" -v green="$GREEN" -v red="$RED" -v yellow="$YELLOW" -v nc="$NC" '
BEGIN {
  un=0; dn=0; uj=0; other=0; load=0; prob_count=0
  uptime_str="Unknown"
}
{
  # 1. Parse Uptime (format from nodetool is usually: Uptime (seconds) : 123456)
  if ($1 == "Uptime") {
    sec = $4
    if (sec ~ /^[0-9]+$/) {
      y = int(sec / 31536000)
      d = int((sec % 31536000) / 86400)
      h = int((sec % 86400) / 3600)
      m = int((sec % 3600) / 60)
      s = int(sec % 60)

      if (y > 0) {
        uptime_str = y "y " d "d " h "h " m "m " s "s"
      } else {
        uptime_str = d "d " h "h " m "m " s "s"
      }
    }
    next
  }

  # 2. Match the 2-letter status codes at the start of the line for cluster status
  if ($1 ~ /^[A-Z][A-Z]$/) {
    if ($1 == "UN") {
      un++;
      load+=$3
    }
    else {
      # Tally the problematic states
      if ($1 == "DN") dn++
      else if ($1 == "UJ") uj++
      else other++

      # Save the problematic node details (Status and IP Address) to an array
      prob_nodes[prob_count] = sprintf("%-4s %s", $1, $2)
      prob_count++
    }
  }
}
END {
  if (un == 0 && dn == 0) {
    print "Waiting for gossip..."
    exit
  }

  # Print Uptime
  printf "Host Uptime:       %s%s%s\n", green, uptime_str, nc

  # Print the Tally
  printf "Up Normal (UN):    %s%d%s\n", green, un, nc

  if (dn > 0) printf "Down Normal (DN):  %s%d%s\n", red, dn, nc
  else printf "Down Normal (DN):  %s0%s\n", green, nc

  if (uj > 0) printf "Joining (UJ):      %s%d%s\n", yellow, uj, nc
  if (other > 0) printf "Other States:      %s%d%s\n", yellow, other, nc

  printf "%sTotal Data Load:%s   %.2f GB\n", cyan, nc, load

  # Print the list of Problematic Nodes if any exist
  if (prob_count > 0) {
    printf "\n%sPROBLEMATIC NODES%s\n", cyan, nc
    for (i = 0; i < prob_count; i++) {
      printf "%s%s%s\n", red, prob_nodes[i], nc
    }
  } else {
    printf "%sAll nodes are Up & Normal.%s\n", green, nc
  }
}'
