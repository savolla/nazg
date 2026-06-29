#!/usr/bin/env bash
# mysql_monitor.sh <etl_host> <mysql_node> <password>
#
# Combines: slow queries, disk/binlog, connections, buffer cache,
#           lock contention, replication, server pulse
# Features: SSH ControlMaster socket (one handshake per run),
#           notify-send alerts, per-environment color badges

ETL_HOST=$1
MYSQL_API_NODE=$2
MYSQL_PASSWORD=$3

CYAN=$'\033[36m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RED=$'\033[31m'
NC=$'\033[0m'

# ─────────────────────────────────────────────
# Environment badge (reuse same logic as k8s helper)
# ─────────────────────────────────────────────
case "$ETL_HOST" in
  *test*|*dev*)
    ENV_BADGE="🔵"; ENV_LABEL="TEST" ;;
  *stag*|*staging*)
    ENV_BADGE="🟠"; ENV_LABEL="STAGING" ;;
  *prod*|*production*)
    ENV_BADGE="🔴"; ENV_LABEL="PROD" ;;
  *)
    ENV_BADGE="⚪"; ENV_LABEL="UNKNOWN" ;;
esac

# ─────────────────────────────────────────────
# SSH ControlMaster — one socket, reused for all queries
# ─────────────────────────────────────────────
SSH_SOCKET="/tmp/mysql-monitor-ssh-${ETL_HOST}"
SSH_OPTS="-q \
  -o ControlMaster=auto \
  -o ControlPath=${SSH_SOCKET} \
  -o ControlPersist=60s \
  -o ConnectTimeout=5 \
  -o BatchMode=yes"

# Open the master connection once; all subsequent ssh calls reuse it
ssh $SSH_OPTS "$ETL_HOST" true 2>/dev/null
if [ $? -ne 0 ]; then
  echo -e "${RED}✗ Cannot reach $ETL_HOST${NC}"
  notify-send --urgency=critical --icon=dialog-error --app-name="mysql-monitor" \
    "${ENV_BADGE} [${ENV_LABEL}] MySQL Unreachable" \
    "Cannot SSH to $ETL_HOST"
  exit 1
fi

# Wrapper: run a mysql command over the shared socket
mysql_run() {
  ssh $SSH_OPTS "$ETL_HOST" \
    "mysql -h $MYSQL_API_NODE -p$MYSQL_PASSWORD -Bse \"$1\" 2>/dev/null"
}

# ─────────────────────────────────────────────
# Notification helper
# ─────────────────────────────────────────────
CACHE_DIR="/tmp/mysql-monitor"
mkdir -p "$CACHE_DIR"

# mysql_notify URGENCY ICON TITLE BODY
mysql_notify() {
  local urgency="$1" icon="$2" title="$3" body="$4"
  notify-send \
    --urgency="$urgency" \
    --icon="$icon" \
    --app-name="mysql-monitor" \
    "${ENV_BADGE} [${ENV_LABEL}] ${title}" \
    "$body"
}

# Debounced notify: fires only when state changes
# debounced_notify CACHE_KEY URGENCY ICON TITLE BODY
debounced_notify() {
  local key="$1" urgency="$2" icon="$3" title="$4" body="$5"
  local cache_file="${CACHE_DIR}/${ETL_HOST}_${key}.cache"
  local current_hash
  current_hash=$(echo "$body" | md5sum)
  local last_hash
  last_hash=$(cat "$cache_file" 2>/dev/null)
  if [ "$current_hash" != "$last_hash" ]; then
    echo "$current_hash" > "$cache_file"
    mysql_notify "$urgency" "$icon" "$title" "$body"
  fi
}

# Clear a debounce cache (call when condition resolves)
debounce_clear() {
  rm -f "${CACHE_DIR}/${ETL_HOST}_${1}.cache"
}

# ─────────────────────────────────────────────
# Fetch all data in as few SSH round-trips as possible
# ─────────────────────────────────────────────

# Batch 1: status metrics (pulse, connections, buffer pool)
BATCH1=$(mysql_run "
  SHOW GLOBAL STATUS WHERE Variable_name IN (
    'Uptime','Threads_connected','Threads_running',
    'Questions','Slow_queries','Opened_tables',
    'Aborted_connects','Aborted_clients','Max_used_connections',
    'Innodb_buffer_pool_reads','Innodb_buffer_pool_read_requests',
    'Innodb_buffer_pool_pages_dirty','Innodb_buffer_pool_pages_total',
    'Innodb_row_lock_waits','Innodb_row_lock_time_avg',
    'Table_locks_waited','Table_locks_immediate'
  );
  SHOW VARIABLES LIKE 'max_connections';
  SELECT @@datadir;
")

# Batch 2: slow queries
SLOW_QUERIES=$(mysql_run "
SELECT ID, USER, TIME, STATE, LEFT(REPLACE(REPLACE(INFO, '\n', ' '), '\r', ''), 40) FROM information_schema.processlist WHERE COMMAND != 'Sleep' AND TIME > 1800 ORDER BY TIME DESC LIMIT 5;
")

# Batch 3: binlogs
BINLOG=$(mysql_run "SHOW BINARY LOGS;")

# Batch 4: lock waits (MySQL 8 first, fall back to MySQL 5.7)
LOCKS=$(mysql_run "
  SELECT r.trx_id, r.trx_mysql_thread_id, r.trx_query,
         b.trx_id, b.trx_mysql_thread_id, b.trx_query,
         TIMESTAMPDIFF(SECOND, r.trx_wait_started, NOW())
  FROM performance_schema.data_lock_waits w
  JOIN information_schema.innodb_trx b ON b.trx_id = w.blocking_engine_transaction_id
  JOIN information_schema.innodb_trx r ON r.trx_id = w.requesting_engine_transaction_id
  ORDER BY 7 DESC LIMIT 5;" 2>/dev/null)

if [ -z "$LOCKS" ]; then
  LOCKS=$(mysql_run "
    SELECT r.trx_id, r.trx_mysql_thread_id, r.trx_query,
           b.trx_id, b.trx_mysql_thread_id, b.trx_query,
           TIMESTAMPDIFF(SECOND, r.trx_wait_started, NOW())
    FROM information_schema.innodb_lock_waits w
    JOIN information_schema.innodb_trx b ON b.trx_id = w.blocking_trx_id
    JOIN information_schema.innodb_trx r ON r.trx_id = w.requesting_trx_id
    ORDER BY 7 DESC LIMIT 5;" 2>/dev/null)
fi

# Batch 5: replication (MySQL 8 first, fall back to 5.7)
REPLICATION=$(mysql_run "SHOW REPLICA STATUS\G" 2>/dev/null)
[ -z "$REPLICATION" ] && REPLICATION=$(mysql_run "SHOW SLAVE STATUS\G" 2>/dev/null)

# Parse BATCH1 into shell variables via awk
eval "$(echo "$BATCH1" | awk '
  function v(val) { gsub(/"/, "\\\"", val); return val }
  {
    if ($1=="Uptime")                        print "DB_UPTIME=\""        v($2) "\""
    if ($1=="Threads_connected")             print "THREADS_CONN=\""     v($2) "\""
    if ($1=="Threads_running")               print "THREADS_RUN=\""      v($2) "\""
    if ($1=="Questions")                     print "QUESTIONS=\""        v($2) "\""
    if ($1=="Slow_queries")                  print "SLOW_Q=\""           v($2) "\""
    if ($1=="Opened_tables")                 print "OPENED_TBL=\""       v($2) "\""
    if ($1=="Aborted_connects")              print "ABORTED_CONN=\""     v($2) "\""
    if ($1=="Aborted_clients")               print "ABORTED_CLI=\""      v($2) "\""
    if ($1=="Max_used_connections")          print "MAX_USED_CONN=\""    v($2) "\""
    if ($1=="max_connections")               print "MAX_CONN=\""         v($2) "\""
    if ($1=="Innodb_buffer_pool_reads")      print "BP_READS=\""         v($2) "\""
    if ($1=="Innodb_buffer_pool_read_requests") print "BP_READ_REQ=\""   v($2) "\""
    if ($1=="Innodb_buffer_pool_pages_dirty") print "BP_DIRTY=\""        v($2) "\""
    if ($1=="Innodb_buffer_pool_pages_total") print "BP_TOTAL=\""        v($2) "\""
    if ($1=="Innodb_row_lock_waits")         print "ROW_LOCK_W=\""       v($2) "\""
    if ($1=="Innodb_row_lock_time_avg")      print "ROW_LOCK_T=\""       v($2) "\""
    if ($1=="Table_locks_waited")            print "TBL_LOCK_W=\""       v($2) "\""
    if ($1=="Table_locks_immediate")         print "TBL_LOCK_I=\""       v($2) "\""
  }
  /^\/.*\/$/ { print "DATADIR=\"" v($1) "\"" }
')"

# ─────────────────────────────────────────────
# Disk usage (needs DATADIR from above)
# ─────────────────────────────────────────────
DISK=""
if [ -n "$DATADIR" ]; then
  DISK=$(ssh $SSH_OPTS "$ETL_HOST" "df -h $DATADIR 2>/dev/null | tail -1")
fi

# ─────────────────────────────────────────────────────────────────────────────
# OUTPUT
# ─────────────────────────────────────────────────────────────────────────────

# ── SERVER PULSE ─────────────────────────────
echo -e "${CYAN}SERVER PULSE${NC}"
uptime_fmt=$(awk -v s="$DB_UPTIME" 'BEGIN {
  d=int(s/86400); h=int((s%86400)/3600); m=int((s%3600)/60)
  if (d>0) printf "%dd %dh %dm", d, h, m
  else if (h>0) printf "%dh %dm", h, m
  else printf "%dm", m
}')
echo -e "Uptime:        ${GREEN}${uptime_fmt}${NC}"
echo -e "Questions:     ${GREEN}${QUESTIONS}${NC}"
echo -e "Slow Queries:  ${GREEN}${SLOW_Q}${NC}"
echo -e "Opened Tables: ${GREEN}${OPENED_TBL}${NC}"
echo ""

# ── CONNECTIONS ──────────────────────────────
echo -e "${CYAN}CONNECTIONS${NC}"
if [ -n "$MAX_CONN" ] && [ "$MAX_CONN" -gt 0 ]; then
  CONN_PCT=$(( THREADS_CONN * 100 / MAX_CONN ))
  if   [ "$CONN_PCT" -ge 85 ]; then CONN_COLOR="$RED"
  elif [ "$CONN_PCT" -ge 70 ]; then CONN_COLOR="$YELLOW"
  else CONN_COLOR="$GREEN"; fi
  echo -e "Open / Limit:  ${CONN_COLOR}${THREADS_CONN}${NC} / ${MAX_CONN} (${CONN_PCT}%)"
  echo -e "Running:       ${GREEN}${THREADS_RUN}${NC}"
  echo -e "High Watermark:${YELLOW}${MAX_USED_CONN}${NC}"
  echo -e "Failed Logins: ${RED}${ABORTED_CONN}${NC}"
  echo -e "Dropped Conns: ${YELLOW}${ABORTED_CLI}${NC}"

  if [ "$CONN_PCT" -ge 85 ]; then
    debounced_notify "conn_critical" critical dialog-error \
      "🔌 MySQL Connections CRITICAL — $ETL_HOST" \
      "Connections at ${CONN_PCT}% of limit (${THREADS_CONN}/${MAX_CONN})"
  elif [ "$CONN_PCT" -ge 70 ]; then
    debounced_notify "conn_warning" normal dialog-warning \
      "🔌 MySQL Connections WARNING — $ETL_HOST" \
      "Connections at ${CONN_PCT}% of limit (${THREADS_CONN}/${MAX_CONN})"
  else
    debounce_clear "conn_critical"
    debounce_clear "conn_warning"
  fi
fi
echo ""

# ── SLOW / STUCK QUERIES ─────────────────────
echo -e "${CYAN}SLOW QUERIES  (>5s)${NC}"
printf "${CYAN}%-10s %-12s %-6s %-40s${NC}\n" "USER" "STATE" "TIME" "QUERY"

# Filter out event-scheduler queries
FILTERED_QUERIES=$(echo "$SLOW_QUERIES" | awk -F'\t' '$2 != "event_scheduler"')

if [ -z "$FILTERED_QUERIES" ]; then
  echo -e "${GREEN}No slow/stuck queries.${NC}"
else
  echo "$FILTERED_QUERIES" | awk -v yellow="$YELLOW" -v red="$RED" -v nc="$NC" -F'\t' '{
    user=$2; time=$3; state=$4; query=$5
    if (length(query)==0) query="<hidden>"
    color = (time+0 > 30) ? red : yellow
    printf "%-10s %-12s %s%4ss%s %-40s\n",
      substr(user,1,10), substr(state,1,12), color, time, nc, substr(query,1,40)
  }'

  # Notify on any slow query >30s
  STUCK=$(echo "$FILTERED_QUERIES" | awk -F'\t' '$3+0>30 {print $2" ("$3"s): "substr($5,1,40)}')
  if [ -n "$STUCK" ]; then
    debounced_notify "slow_query" normal dialog-error \
      "🐢 MySQL STUCK QUERIES — $ETL_HOST" \
      "$STUCK"
  else
    debounced_notify "slow_query_warn" normal dialog-warning \
      "🐢 MySQL Slow Queries — $ETL_HOST" \
      "$(echo "$FILTERED_QUERIES" | wc -l) query/queries running >5s"
    debounce_clear "slow_query"
  fi
fi
echo ""

# ── DISK & BINLOG ────────────────────────────
echo -e "${CYAN}DISK & BINLOG${NC}"
if [ -n "$BINLOG" ]; then
  eval "$(echo "$BINLOG" | awk '
    BEGIN { count=0; total=0 }
    { count++; total+=$2 }
    END {
      print "BINLOG_COUNT=" count
      print "BINLOG_TOTAL_MB=" int(total/1024/1024)
    }
  ')"
  if   [ "$BINLOG_TOTAL_MB" -gt 10240 ]; then BL_COLOR="$RED"
  elif [ "$BINLOG_TOTAL_MB" -gt 2048  ]; then BL_COLOR="$YELLOW"
  else BL_COLOR="$GREEN"; fi
  echo -e "Binlog Files:  ${GREEN}${BINLOG_COUNT}${NC}"
  echo -e "Binlog Total:  ${BL_COLOR}${BINLOG_TOTAL_MB}MB${NC}"

  if [ "$BINLOG_TOTAL_MB" -gt 51200 ]; then
    debounced_notify "binlog" critical dialog-error \
      "💾 MySQL Binlog CRITICAL — $ETL_HOST" \
      "Binlog total: ${BINLOG_TOTAL_MB}MB (>${51200}MB threshold)"
  else
    debounce_clear "binlog"
  fi
fi

if [ -n "$DISK" ]; then
  eval "$(echo "$DISK" | awk '{
    pct=substr($5,1,length($5)-1)+0
    print "DISK_PCT=" pct
    print "DISK_USED=\"" $5 "\""
    print "DISK_FREE=\"" $4 "\""
    print "DISK_DIR=\""  $6 "\""
  }')"
  if   [ "$DISK_PCT" -ge 85 ]; then DISK_COLOR="$RED"
  elif [ "$DISK_PCT" -ge 70 ]; then DISK_COLOR="$YELLOW"
  else DISK_COLOR="$GREEN"; fi
  echo -e "Data Dir:      ${DISK_DIR}"
  echo -e "Disk Used:     ${DISK_COLOR}${DISK_USED}${NC}  (free: ${DISK_FREE})"

  if [ "$DISK_PCT" -ge 85 ]; then
    debounced_notify "disk" critical dialog-error \
      "💽 MySQL Disk CRITICAL — $ETL_HOST" \
      "Disk at ${DISK_USED} used on ${DISK_DIR} (${DISK_FREE} free)"
  elif [ "$DISK_PCT" -ge 70 ]; then
    debounced_notify "disk" normal dialog-warning \
      "💽 MySQL Disk WARNING — $ETL_HOST" \
      "Disk at ${DISK_USED} used on ${DISK_DIR} (${DISK_FREE} free)"
  else
    debounce_clear "disk"
  fi
fi
echo ""

# ── BUFFER POOL ──────────────────────────────
echo -e "${CYAN}CACHE EFFICIENCY${NC}"
eval "$(awk -v reads="$BP_READS" -v reqs="$BP_READ_REQ" \
            -v dirty="$BP_DIRTY" -v total="$BP_TOTAL" 'BEGIN {
  hit = (reqs+0 > 0) ? 100 - ((reads/reqs)*100) : 100
  dp  = (total+0 > 0) ? (dirty/total)*100 : 0
  printf "BP_HIT_RATE=%.2f\n", hit
  printf "BP_DIRTY_PCT=%.2f\n", dp
}')"

if   awk "BEGIN{exit !($BP_HIT_RATE < 90)}"; then HR_COLOR="$RED"
elif awk "BEGIN{exit !($BP_HIT_RATE < 95)}"; then HR_COLOR="$YELLOW"
else HR_COLOR="$GREEN"; fi

if   awk "BEGIN{exit !($BP_DIRTY_PCT > 10)}"; then DP_COLOR="$RED"
elif awk "BEGIN{exit !($BP_DIRTY_PCT > 5)}";  then DP_COLOR="$YELLOW"
else DP_COLOR="$GREEN"; fi

echo -e "Buffer Hit Rate: ${HR_COLOR}${BP_HIT_RATE}%${NC}"
echo -e "Dirty Pages:     ${DP_COLOR}${BP_DIRTY_PCT}%${NC}"

if awk "BEGIN{exit !($BP_HIT_RATE < 90)}"; then
  debounced_notify "buffer" critical dialog-error \
    "🧠 MySQL Buffer Pool CRITICAL — $ETL_HOST" \
    "Hit rate: ${BP_HIT_RATE}% (below 90%)\nDirty pages: ${BP_DIRTY_PCT}%"
elif awk "BEGIN{exit !($BP_HIT_RATE < 95)}"; then
  debounced_notify "buffer" normal dialog-warning \
    "🧠 MySQL Buffer Pool WARNING — $ETL_HOST" \
    "Hit rate: ${BP_HIT_RATE}% (below 95%)"
else
  debounce_clear "buffer"
fi
echo ""

# ── LOCK CONTENTION ──────────────────────────
echo -e "${CYAN}LOCK CONTENTION${NC}"
if   [ "${ROW_LOCK_W:-0}" -gt 100 ]; then RLW_COLOR="$RED"
elif [ "${ROW_LOCK_W:-0}" -gt 10  ]; then RLW_COLOR="$YELLOW"
else RLW_COLOR="$GREEN"; fi
echo -e "Row Lock Waits:  ${RLW_COLOR}${ROW_LOCK_W:-0}${NC}"
echo -e "Avg Lock Time:   ${GREEN}${ROW_LOCK_T:-0}ms${NC}"

TBL_TOTAL=$(( ${TBL_LOCK_W:-0} + ${TBL_LOCK_I:-1} ))
TBL_WPCT=$(( TBL_TOTAL > 0 ? TBL_LOCK_W * 100 / TBL_TOTAL : 0 ))
if   [ "$TBL_WPCT" -gt 10 ]; then TW_COLOR="$RED"
elif [ "$TBL_WPCT" -gt 2  ]; then TW_COLOR="$YELLOW"
else TW_COLOR="$GREEN"; fi
echo -e "Table Lock Wait: ${TW_COLOR}${TBL_WPCT}%${NC}  (${TBL_LOCK_W:-0} waited / ${TBL_LOCK_I:-0} immediate)"

if [ -z "$LOCKS" ]; then
  echo -e "${GREEN}No active lock waits.${NC}"
else
  printf "${CYAN}%-6s %-6s %-8s %-35s${NC}\n" "W.TRX" "B.TRX" "WAIT(s)" "WAITING QUERY"
  echo "$LOCKS" | awk -v yellow="$YELLOW" -v red="$RED" -v nc="$NC" -F'\t' '{
    wait=$7+0
    color = (wait>10) ? red : yellow
    printf "%-6s %-6s %s%6ss%s %-35s\n", $1, $4, color, $7, nc, substr($3,1,35)
  }'

  MAX_WAIT=$(echo "$LOCKS" | awk -F'\t' 'BEGIN{m=0} {if($7+0>m)m=$7+0} END{print m}')
  if [ "${MAX_WAIT:-0}" -gt 10 ]; then
    debounced_notify "locks" critical dialog-error \
      "🔒 MySQL Lock Wait CRITICAL — $ETL_HOST" \
      "Lock wait of ${MAX_WAIT}s detected"
  else
    debounced_notify "locks" normal dialog-warning \
      "🔒 MySQL Lock Contention — $ETL_HOST" \
      "Active lock waits present"
  fi
fi

if [ "${ROW_LOCK_W:-0}" -gt 100 ]; then
  debounced_notify "row_locks" critical dialog-error \
    "🔒 MySQL Row Locks CRITICAL — $ETL_HOST" \
    "Row lock waits: ${ROW_LOCK_W} (avg ${ROW_LOCK_T}ms)"
fi
echo ""

# ── Failed login spike detection ─────────────
CONN_CACHE="${CACHE_DIR}/${ETL_HOST}_aborted_conn.cache"
PREV_ABORTED=$(cat "$CONN_CACHE" 2>/dev/null)
echo "$ABORTED_CONN" > "$CONN_CACHE"

if [ -n "$PREV_ABORTED" ] && [ "$ABORTED_CONN" -gt "$PREV_ABORTED" ]; then
  NEW_FAILURES=$(( ABORTED_CONN - PREV_ABORTED ))
  debounced_notify "failed_logins" normal dialog-error \
    "🔑 MySQL Failed Logins — $ETL_HOST" \
    "${NEW_FAILURES} new failed login(s) detected (total: ${ABORTED_CONN})"
else
  debounce_clear "failed_logins"
fi

# ── REPLICATION ──────────────────────────────
echo -e "${CYAN}REPLICATION${NC}"
if [ -z "$REPLICATION" ]; then
  echo -e "${YELLOW}Not a replica node (or no access)${NC}"
else
  eval "$(echo "$REPLICATION" | awk '
    { gsub(/^[ \t]+/, "") }
    /^Slave_IO_Running:|^Replica_IO_Running:/   { print "REPL_IO=\""     $2 "\"" }
    /^Slave_SQL_Running:|^Replica_SQL_Running:/  { print "REPL_SQL=\""    $2 "\"" }
    /^Seconds_Behind_Source:|^Seconds_Behind_Master:/ { print "REPL_LAG=\"" $2 "\"" }
    /^Source_Host:|^Master_Host:/                { print "REPL_MASTER=\"" $2 "\"" }
    /^Relay_Log_Space:/                          { print "RELAY_SPACE=\"" $2 "\"" }
    /^Last_Error:/ { $1=""; print "REPL_ERR=\"" substr($0,2) "\"" }
  ')"

  IO_COLOR="$( [ "$REPL_IO"  = "Yes" ] && echo "$GREEN" || echo "$RED" )"
  SQL_COLOR="$( [ "$REPL_SQL" = "Yes" ] && echo "$GREEN" || echo "$RED" )"
  echo -e "IO Thread:     ${IO_COLOR}${REPL_IO:-?}${NC}"
  echo -e "SQL Thread:    ${SQL_COLOR}${REPL_SQL:-?}${NC}"

  if [ "$REPL_LAG" = "NULL" ]; then
    echo -e "Lag:           ${RED}NULL (IO thread down or no source)${NC}"
  else
    LAG_N="${REPL_LAG:-0}"
    if   [ "$LAG_N" -gt 30 ]; then LAG_COLOR="$RED"
    elif [ "$LAG_N" -gt 5  ]; then LAG_COLOR="$YELLOW"
    else LAG_COLOR="$GREEN"; fi
    echo -e "Lag:           ${LAG_COLOR}${REPL_LAG}s${NC}"
  fi

  [ "$REPL_IO" = "Yes" ] && [ "$REPL_SQL" = "Yes" ] && [ "$REPL_LAG" = "NULL" ] && \
    echo -e "${YELLOW}⚠  Both threads running but lag=NULL — check source connection${NC}"

  echo -e "Source:        ${GREEN}${REPL_MASTER:-?}${NC}"

  RELAY_MB=$(( ${RELAY_SPACE:-0} / 1024 / 1024 ))
  if   [ "$RELAY_MB" -gt 500 ]; then RL_COLOR="$RED"
  elif [ "$RELAY_MB" -gt 100 ]; then RL_COLOR="$YELLOW"
  else RL_COLOR="$GREEN"; fi
  echo -e "Relay Log:     ${RL_COLOR}${RELAY_MB}MB${NC}"

  [ -n "$REPL_ERR" ] && [ "${#REPL_ERR}" -gt 1 ] && \
    echo -e "Last Error:    ${RED}${REPL_ERR:0:60}${NC}"

  # Notifications
  REPL_PROBLEMS=""
  [ "$REPL_IO"  != "Yes" ] && REPL_PROBLEMS+="IO thread DOWN\n"
  [ "$REPL_SQL" != "Yes" ] && REPL_PROBLEMS+="SQL thread DOWN\n"
  [ "$REPL_LAG" != "NULL" ] && [ "${REPL_LAG:-0}" -gt 30 ] && \
    REPL_PROBLEMS+="Lag: ${REPL_LAG}s\n"
  [ -n "$REPL_ERR" ] && [ "${#REPL_ERR}" -gt 1 ] && \
    REPL_PROBLEMS+="Error: ${REPL_ERR:0:60}\n"

  if [ -n "$REPL_PROBLEMS" ]; then
    debounced_notify "replication" critical dialog-error \
      "🔁 MySQL Replication CRITICAL — $ETL_HOST" \
      "$REPL_PROBLEMS"
  else
    debounce_clear "replication"
  fi
fi
