#!/usr/bin/env bash

ETL_HOST=$1
MYSQL_API_NODE=$2
MYSQL_PASSWORD=$3

CYAN=$'\033[36m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RED=$'\033[31m'
NC=$'\033[0m'

QUERY="SHOW GLOBAL STATUS LIKE 'Innodb_buffer_pool_read%'; SHOW GLOBAL STATUS LIKE 'Innodb_buffer_pool_pages_dirty'; SHOW GLOBAL STATUS LIKE 'Innodb_buffer_pool_pages_total';"

DATA=$(ssh -q "$ETL_HOST" "mysql -h $MYSQL_API_NODE -p$MYSQL_PASSWORD -Bse \"$QUERY\" 2>/dev/null")

if [ -z "$DATA" ]; then exit 1; fi

echo "$DATA" | awk -v cyan="$CYAN" -v green="$GREEN" -v yellow="$YELLOW" -v red="$RED" -v nc="$NC" '
{
  if ($1 == "Innodb_buffer_pool_reads") disk_reads = $2
  if ($1 == "Innodb_buffer_pool_read_requests") total_reads = $2
  if ($1 == "Innodb_buffer_pool_pages_dirty") dirty = $2
  if ($1 == "Innodb_buffer_pool_pages_total") total_pages = $2
}
END {
  # Calculate Hit Rate
  hit_rate = 100
  if (total_reads > 0) {
    hit_rate = 100 - ((disk_reads / total_reads) * 100)
  }

  hit_color = green
  if (hit_rate < 90) hit_color = red
  else if (hit_rate < 95) hit_color = yellow

  # Calculate Dirty Pages %
  dirty_pct = 0
  if (total_pages > 0) {
    dirty_pct = (dirty / total_pages) * 100
  }

  dirty_color = green
  if (dirty_pct > 10) dirty_color = red
  else if (dirty_pct > 5) dirty_color = yellow

  printf "%sCACHE EFFICIENCY%s\n", cyan, nc
  printf "Buffer Hit Rate: %s%.2f%%%s\n", hit_color, hit_rate, nc
  printf "Dirty Pages:     %s%.2f%%%s\n", dirty_color, dirty_pct, nc
}'
