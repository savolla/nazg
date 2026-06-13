#!/usr/bin/env bash

ETL_HOST=$1
MYSQL_API_NODE=$2
MYSQL_PASSWORD=$3

CYAN=$'\033[36m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RED=$'\033[31m'
NC=$'\033[0m'

# Query current connections and the max limit
DATA=$(ssh -q $ETL_HOST "mysql -h $MYSQL_API_NODE -p$MYSQL_PASSWORD -Bse \"SHOW GLOBAL STATUS LIKE 'Threads_connected'; SHOW VARIABLES LIKE 'max_connections';\"")

if [ -z "$DATA" ]; then
  echo -e "${RED}Connection error${NC}"
  exit 1
fi

echo "$DATA" | awk -v cyan="$CYAN" -v green="$GREEN" -v yellow="$YELLOW" -v red="$RED" -v nc="$NC" '
BEGIN { current=0; max=0 }
{
  if ($1 == "Threads_connected") current = $2
  if ($1 == "max_connections") max = $2
}
END {
  if (max > 0) {
    pct = int((current / max) * 100)
    color = green
    if (pct >= 85) color = red
    else if (pct >= 70) color = yellow

    printf "%sCONNECTIONS%s\n", cyan, nc
    printf "Active: %s%s%s / %s (%s%%)\n", color, current, nc, max, pct
  }
}'
