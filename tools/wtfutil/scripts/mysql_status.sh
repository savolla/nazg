#!/usr/bin/env bash

ETL_HOST=$1
MYSQL_API_NODE=$2
MYSQL_PASSWORD=$3

CYAN=$'\033[36m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RED=$'\033[31m'
NC=$'\033[0m'

# Fetch raw status from mysqladmin
STATUS=$(ssh -q "$ETL_HOST" "mysqladmin status -h $MYSQL_API_NODE -p$MYSQL_PASSWORD 2>/dev/null")
if [ -z "$STATUS" ]; then
  echo -e "${RED}Failed to connect to MySQL via $ETL_HOST${NC}"
  exit 1
fi

# Fetch detailed connection metrics
SQL_QUERY="
SHOW GLOBAL STATUS WHERE Variable_name IN ('Threads_connected', 'Threads_running', 'Aborted_connects', 'Aborted_clients', 'Max_used_connections');
SHOW VARIABLES LIKE 'max_connections';
"
CONNECTIONS=$(ssh -q "$ETL_HOST" "mysql -h $MYSQL_API_NODE -p$MYSQL_PASSWORD -Bse \"$SQL_QUERY\" 2>/dev/null")

if [ -z "$CONNECTIONS" ]; then
  echo -e "${RED}Connection error${NC}"
  exit 1
fi

echo -e "${CYAN}SERVER PULSE${NC}"

# Format the standard mysqladmin output
echo "$STATUS" | awk -v green="$GREEN" -v nc="$NC" '
{
  printf "Uptime:        %s%s %s %s %s%s\n", green, $2, $3, $4, $5, nc
  printf "Threads:       %s%s%s\n", green, $7, nc
  printf "Questions:     %s%s%s\n", green, $9, nc
  printf "Slow Queries:  %s%s%s\n", green, $12, nc
  printf "Opens:         %s%s%s\n", green, $14, nc
  printf "Flush Tables:  %s%s%s\n", green, $17, nc
  printf "Queries/sec:   %s%s%s\n", green, $22, nc
}'

echo ""

# Format the connections data
echo "$CONNECTIONS" | awk -v cyan="$CYAN" -v green="$GREEN" -v yellow="$YELLOW" -v red="$RED" -v nc="$NC" '
BEGIN { conn=0; run=0; ab_conn=0; ab_client=0; max_used=0; max_limit=0 }
{
  if ($1 == "Threads_connected") conn = $2
  if ($1 == "Threads_running") run = $2
  if ($1 == "Aborted_connects") ab_conn = $2
  if ($1 == "Aborted_clients") ab_client = $2
  if ($1 == "Max_used_connections") max_used = $2
  if ($1 == "max_connections") max_limit = $2
}
END {
  if (max_limit > 0) {
    pct = int((conn / max_limit) * 100)
    color = green
    if (pct >= 85) color = red
    else if (pct >= 70) color = yellow

    printf "%sCONNECTIONS%s\n", cyan, nc
    printf "Open / Limit:  %s%s%s / %s (%s%%)\n", color, conn, nc, max_limit, pct
    printf "Actively Rng:  %s%s%s\n", green, run, nc
    printf "High Watermk:  %s%s%s\n", yellow, max_used, nc
    printf "Failed Logins: %s%s%s\n", red, ab_conn, nc
    printf "Dropped Ntwk:  %s%s%s\n", yellow, ab_client, nc
  }
}'
