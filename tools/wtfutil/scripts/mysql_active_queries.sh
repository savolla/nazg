#!/usr/bin/env bash

ETL_HOST=$1
MYSQL_API_NODE=$2
MYSQL_PASSWORD=$3

CYAN=$'\033[36m'
YELLOW=$'\033[33m'
GREEN=$'\033[32m'
NC=$'\033[0m'

# Fetch queries running longer than 5 seconds, ignoring Sleep state
QUERY="SELECT ID, USER, TIME, STATE, LEFT(REPLACE(REPLACE(INFO, '\n', ' '), '\r', ''), 40) FROM information_schema.processlist WHERE COMMAND != 'Sleep' AND TIME > 5 ORDER BY TIME DESC LIMIT 5;"

DATA=$(ssh -q "$ETL_HOST" "mysql -h $MYSQL_API_NODE -p$MYSQL_PASSWORD -Bse \"$QUERY\" 2>/dev/null")

printf "${CYAN}%-10s %-12s %-6s %-30s${NC}\n" "USER" "STATE" "TIME" "QUERY"

if [ -z "$DATA" ]; then
  echo -e "${GREEN}No slow/stuck queries currently running.${NC}"
else
  echo "$DATA" | awk -v yellow="$YELLOW" -v nc="$NC" -F'\t' '{
    user=$2; time=$3; state=$4; query=$5;
    if (length(query) == 0) query="<hidden>"
    printf "%-10s %-12s %s%4ss%s %-30s\n", substr(user,1,10), substr(state,1,12), yellow, time, nc, query
  }'
fi
