#!/usr/bin/env bash
# mysql_replication.sh <etl_host> <replica_node> <password>
ETL_HOST=$1; MYSQL_API_NODE=$2; MYSQL_PASSWORD=$3

CYAN=$'\033[36m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; RED=$'\033[31m'; NC=$'\033[0m'

DATA=$(ssh -q "$ETL_HOST" "mysql -h $MYSQL_API_NODE -p$MYSQL_PASSWORD -e 'SHOW SLAVE STATUS\G' 2>/dev/null")

if [ -z "$DATA" ]; then
  echo -e "${YELLOW}Not a replica node (or no access)${NC}"
  exit 0
fi

echo -e "${CYAN}REPLICATION${NC}"

echo "$DATA" | awk -v green="$GREEN" -v yellow="$YELLOW" -v red="$RED" -v nc="$NC" '
{
  gsub(/^[ \t]+/, "")
  if ($1 == "Slave_IO_Running:")      io=$2
  if ($1 == "Slave_SQL_Running:")     sql=$2
  if ($1 == "Seconds_Behind_Master:") lag=$2
  if ($1 == "Last_Error:")            { $1=""; err=substr($0,2) }
  if ($1 == "Master_Host:")           master=$2
  if ($1 == "Relay_Log_Space:")       relay=$2
}
END {
  # IO thread
  color = (io == "Yes") ? green : red
  printf "IO Thread:     %s%s%s\n", color, io, nc

  # SQL thread
  color = (sql == "Yes") ? green : red
  printf "SQL Thread:    %s%s%s\n", color, sql, nc

  # Lag
  if (lag == "NULL") {
    printf "Lag:           %sNULL (IO thread down or no master)%s\n", red, nc
  } else {
    lag_n = lag + 0
    color = (lag_n > 30) ? red : (lag_n > 5) ? yellow : green
    printf "Lag:           %s%ss%s\n", color, lag, nc
  }

  # Catch the silent failure: threads running but NULL lag
  if (io == "Yes" && sql == "Yes" && lag == "NULL") {
    printf "%s⚠  Both threads running but lag=NULL — check master connection%s\n", yellow, nc
  }

  printf "Master:        %s%s%s\n", green, master, nc

  relay_mb = int(relay / 1024 / 1024)
  color = (relay_mb > 500) ? red : (relay_mb > 100) ? yellow : green
  printf "Relay Log:     %s%sMB%s\n", color, relay_mb, nc

  if (length(err) > 1) {
    printf "Last Error:    %s%s%s\n", red, substr(err,1,60), nc
  }
}'
