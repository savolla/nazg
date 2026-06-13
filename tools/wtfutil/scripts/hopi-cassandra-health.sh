#!/usr/bin/env bash

CASS_NODE="$1"
JMX_MONITORING_USER="$2"
JMX_MONITORING_PASS="$3"

CYAN=$'\033[36m'
GREEN=$'\033[32m'
YELLOW=$'\033[33m'
RED=$'\033[31m'
BOLD=$'\033[1m'
NC=$'\033[0m'

# ── Step 1: get all node IPs from the ring ──────────────────────────────────
RING_NODES=$(ssh -q "$CASS_NODE" \
  "nodetool -h localhost -u $JMX_MONITORING_USER -pw $JMX_MONITORING_PASS status 2>/dev/null \
   | awk '/^(UN|DN|UL|UJ|DJ)/{print \$2}'"
)

if [ -z "$RING_NODES" ]; then
  echo "Failed to fetch ring nodes from $CASS_NODE" >&2
  exit 1
fi

# ── Step 2: collect metrics from each node in parallel ──────────────────────
TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

collect_node() {
  local node=$1
  local user=$2
  local pass=$3
  local outfile=$4

  local data
  data=$(ssh -q -o ConnectTimeout=5 -o StrictHostKeyChecking=no "$node" \
    "nodetool -h localhost -u $user -pw $pass info 2>/dev/null; \
     echo '---'; \
     nodetool -h localhost -u $user -pw $pass compactionstats 2>/dev/null; \
     echo '---'; \
     hostname" 2>/dev/null)

  [ -z "$data" ] && echo "UNREACHABLE" > "$outfile" && return

  echo "$data" > "$outfile"
}

pids=()
nodes=()
for node in $RING_NODES; do
  outfile="$TMPDIR/$node"
  collect_node "$node" "$JMX_MONITORING_USER" "$JMX_MONITORING_PASS" "$outfile" &
  pids+=($!)
  nodes+=("$node")
done

# Wait for all background SSH jobs
for pid in "${pids[@]}"; do
  wait "$pid"
done

# ── Step 3: print results ────────────────────────────────────────────────────
format_uptime() {
  local secs=$1
  local result=""

  local y=$(( secs / 31536000 )); secs=$(( secs % 31536000 ))
  local mo=$(( secs / 2592000 )); secs=$(( secs % 2592000 ))
  local d=$(( secs / 86400 ));  secs=$(( secs % 86400 ))
  local h=$(( secs / 3600 ));   secs=$(( secs % 3600 ))
  local m=$(( secs / 60 ))

  [ $y -gt 0 ]  && result+="${y}y "
  [ $mo -gt 0 ] && result+="${mo}mo "
  [ $d -gt 0 ]  && result+="${d}d "
  [ $h -gt 0 ]  && result+="${h}h "
  [ $m -gt 0 ]  && result+="${m}m"

  echo "${result:-0m}"
}

for node in "${nodes[@]}"; do
  outfile="$TMPDIR/$node"

  if [ ! -f "$outfile" ] || grep -q "^UNREACHABLE$" "$outfile"; then
    echo -e "${RED}✗ Unreachable${NC}"
    continue
  fi

  # Parse with awk, then format uptime in bash
  parsed=$(awk -F' : ' '
    /^Uptime/         { uptime_sec = $2 }
    /^Heap Memory/    { split($2, h, " / "); heap_used = h[1]; split(h[2], h2, " "); heap_total = h2[1] }
    /^Load/           { load = $2 }
    /^pending tasks:/ { split($0, p, ":"); pending = p[2]+0 }
    /^---$/           { section++ }
    section == 2 && NF > 0 { hostname = $0 }
    END {
      printf "%s|%s|%s|%s|%s\n", uptime_sec, heap_used, heap_total, pending+0, hostname
    }
  ' "$outfile")

  IFS='|' read -r uptime_sec heap_used heap_total pending hostname <<< "$parsed"

  # Human-readable uptime
  uptime_str=$(format_uptime "${uptime_sec:-0}")

  # Heap color
  pct=0
  if [ "${heap_total%.*}" -gt 0 ] 2>/dev/null; then
    pct=$(awk "BEGIN { printf \"%d\", ($heap_used / $heap_total) * 100 }")
  fi
  if   [ "$pct" -ge 85 ]; then heap_color=$RED
  elif [ "$pct" -ge 75 ]; then heap_color=$YELLOW
  else heap_color=$GREEN
  fi

  # Compaction color
  pending=${pending:-0}
  if   [ "$pending" -ge 50 ]; then comp_color=$RED
  elif [ "$pending" -ge 20 ]; then comp_color=$YELLOW
  else comp_color=$GREEN
  fi

  hostname=$(echo "$hostname" | tr -d '[:space:]')

  echo -e "Node:         ${BOLD}${CYAN}${hostname:-unknown}${NC} (${node})"
  echo -e "Uptime:       ${GREEN}${uptime_str}${NC}"
  echo -e "Heap Memory:  ${heap_color}${heap_used} / ${heap_total} MB (${pct}%)${NC}"
  echo -e "Pending Comp: ${comp_color}${pending}${NC} tasks"
  echo -e ""
done

echo ""
