#!/usr/bin/env bash
# mysql_disk.sh <etl_host> <mysql_node> <password>
ETL_HOST=$1; MYSQL_API_NODE=$2; MYSQL_PASSWORD=$3

CYAN=$'\033[36m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; RED=$'\033[31m'; NC=$'\033[0m'

BINLOG=$(ssh -q "$ETL_HOST" "mysql -h $MYSQL_API_NODE -p$MYSQL_PASSWORD -Bse 'SHOW BINARY LOGS;' 2>/dev/null")
DATADIR=$(ssh -q "$ETL_HOST" "mysql -h $MYSQL_API_NODE -p$MYSQL_PASSWORD -Bse \"SELECT @@datadir;\" 2>/dev/null")

echo -e "${CYAN}DISK & BINLOG${NC}"

if [ -n "$BINLOG" ]; then
  echo "$BINLOG" | awk -v green="$GREEN" -v yellow="$YELLOW" -v red="$RED" -v nc="$NC" '
  BEGIN { count=0; total=0 }
  { count++; total += $2 }
  END {
    total_mb = int(total / 1024 / 1024)
    color = (total_mb > 10240) ? red : (total_mb > 2048) ? yellow : green
    printf "Binlog Files:  %s%s%s\n", green, count, nc
    printf "Binlog Total:  %s%sMB%s\n", color, total_mb, nc
  }'
fi

if [ -n "$DATADIR" ]; then
  DISK=$(ssh -q "$ETL_HOST" "df -h $DATADIR 2>/dev/null | tail -1")
  echo "$DISK" | awk -v green="$GREEN" -v yellow="$YELLOW" -v red="$RED" -v nc="$NC" '{
    used_pct = substr($5, 1, length($5)-1) + 0
    color = (used_pct > 85) ? red : (used_pct > 70) ? yellow : green
    printf "Data Dir:      %s\n", $6
    printf "Disk Used:     %s%s%s  (free: %s)\n", color, $5, nc, $4
  }'
fi
