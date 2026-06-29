#!/usr/bin/env bash

K8S_CONTEXT=$1
source "$(dirname "$0")/k8s-context-aware-notification-helper.sh"
NAMESPACE=${2:-default}

CACHE_DIR="/tmp/k8s-version-monitor"
mkdir -p "$CACHE_DIR"
CACHE="${CACHE_DIR}/${K8S_CONTEXT}_${NAMESPACE}.cache"

# --- Collect current versions ---
CURRENT=$(for deploy in $(kubectl get --context "$K8S_CONTEXT" deploy -n "$NAMESPACE" -o jsonpath='{.items[*].metadata.name}' 2>/dev/null); do
  kubectl --context "$K8S_CONTEXT" get deploy "$deploy" -n "$NAMESPACE" -o yaml 2>/dev/null \
    | yq -r '.spec.template.spec.containers[] | "\(.name): \(.image | split(":")[-1])"'
done | sort)

# --- Diff against cache and notify ---
if [ -f "$CACHE" ]; then
  PREV="$(<"$CACHE")"

  if [ "$CURRENT" != "$PREV" ]; then
    # Lines only in PREV  → removed/downgraded (old version)
    # Lines only in CURRENT → added/upgraded   (new version)
    while IFS= read -r line; do
      [[ -z "$line" ]] && continue

      name="${line%%:*}"
      old_ver=$(grep -F "${name}:" "$CACHE"    | awk '{print $NF}')
      new_ver=$(echo "$CURRENT" | grep -F "${name}:" | awk '{print $NF}')

      if [ -z "$new_ver" ]; then
        # Service removed entirely
        notify-send \
          --urgency=normal \
          --icon=dialog-information \
          -app-name="k8s-monitor" \
          "K8s SERVICE DOWNGRADED — $K8S_CONTEXT/$NAMESPACE" \
          "${name} was removed (was ${old_ver})"

      elif [ -z "$old_ver" ]; then
        # Brand-new service
        notify-send \
          --urgency=normal \
          --icon=dialog-information \
          --app-name="k8s-monitor" \
          "K8s NEW — $K8S_CONTEXT/$NAMESPACE" \
          "${name} deployed at ${new_ver}"

      elif [ "$old_ver" != "$new_ver" ]; then
        # Determine upgrade vs downgrade heuristically via sort -V
        HIGHER=$(printf '%s\n%s\n' "$old_ver" "$new_ver" | sort -V | tail -1)
        if [ "$HIGHER" = "$new_ver" ]; then
          ARROW="⬆️ upgraded"
          ICON="software-update-available"
        else
          ARROW="⬇️ downgraded"
          ICON="dialog-warning"
        fi

        notify-send \
          --urgency=normal \
          --icon="$ICON" \
          --app-name="k8s-monitor" \
          "K8s ${ARROW^^} — $K8S_CONTEXT/$NAMESPACE" \
          "${name}: ${old_ver}  →  ${new_ver}"
      fi

    done < <(comm -3 \
      <(echo "$PREV"    | sort) \
      <(echo "$CURRENT" | sort) \
      | sed 's/^\t//')   # strip leading tab that comm adds for right-only lines
  fi
fi

# Always update cache
echo "$CURRENT" > "$CACHE"

# --- Terminal output (unchanged behaviour) ---
echo "$CURRENT" | column -t
echo ""
