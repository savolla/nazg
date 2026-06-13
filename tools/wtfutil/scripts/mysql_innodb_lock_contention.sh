#!/usr/bin/env bash
# mysql_locks.sh <etl_host> <mysql_node> <password>
ETL_HOST=$1; MYSQL_API_NODE=$2; MYSQL_PASSWORD=$3

CYAN=$'\033[36m'; GREEN=$'\033[32m'; YELLOW=$'\033[33m'; RED=$'\033[31m'; NC=$'\033[0m'

LOCK_QUERY="
SELECT r.trx_id waiting_trx,
       r.trx_mysql_thread_id waiting_thread,
       r.trx_query waiting_query,
       b.trx_id blocking_trx,
       b.trx_mysql_thread_id blocking_thread,
       b.trx_query blocking_query,
       TIMESTAMPDIFF(SECOND, r.trx_wait_started, NOW()) wait_secs
FROM information_schema.innodb_lock_waits w
JOIN information_schema.innodb_trx b ON b.trx_id = w.blocking_trx_id
JOIN information_schema.innodb_trx r ON r.trx_id = w.requesting_trx_id
ORDER BY wait_secs DESC LIMIT 5;"

STAT_QUERY="
SELECT Variable_name, Variable_value FROM information_schema.GLOBAL_STATUS
WHERE Variable_name IN ('Innodb_row_lock_waits','Innodb_row_lock_time_avg','Table_locks_waited','Table_locks_immediate');"

LOCKS=$(ssh -q "$ETL_HOST" "mysql -h $MYSQL_API_NODE -p$MYSQL_PASSWORD -Bse \"$LOCK_QUERY\" 2>/dev/null")
STATS=$(ssh -q "$ETL_HOST" "mysql -h $MYSQL_API_NODE -p$MYSQL_PASSWORD -Bse \"$STAT_QUERY\" 2>/dev/null")

echo -e "${CYAN}LOCK CONTENTION${NC}"

echo "$STATS" | awk -v green="$GREEN" -v yellow="$YELLOW" -v red="$RED" -v nc="$NC" '
{
  if ($1=="Innodb_row_lock_waits")     rw=$2
  if ($1=="Innodb_row_lock_time_avg")  rt=$2
  if ($1=="Table_locks_waited")        tw=$2
  if ($1=="Table_locks_immediate")     ti=$2
}
END {
  color = (rw > 100) ? red : (rw > 10) ? yellow : green
  printf "Row Lock Waits:  %s%s%s\n", color, rw, nc
  printf "Avg Lock Time:   %s%sms%s\n", green, rt, nc

  total = tw + ti
  if (total > 0) {
    wpct = int((tw / total) * 100)
    color = (wpct > 10) ? red : (wpct > 2) ? yellow : green
    printf "Table Lock Wait: %s%d%%%s  (%s waited / %s immediate)\n", color, wpct, nc, tw, ti
  }
}'

echo ""

if [ -z "$LOCKS" ]; then
  echo -e "${GREEN}No active lock waits.${NC}"
else
  printf "${CYAN}%-6s %-6s %-8s %-35s${NC}\n" "W.TRX" "B.TRX" "WAIT(s)" "WAITING QUERY"
  echo "$LOCKS" | awk -v yellow="$YELLOW" -v red="$RED" -v nc="$NC" -F'\t' '{
    wait=$7+0
    color = (wait > 10) ? red : yellow
    printf "%-6s %-6s %s%6ss%s %-35s\n", $1, $4, color, $7, nc, substr($3,1,35)
  }'
fi
