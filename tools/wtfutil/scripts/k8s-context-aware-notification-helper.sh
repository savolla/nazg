#!/usr/bin/env bash
# k8s-notify-helper.sh
# Source this file in your monitor scripts:
#   source "$(dirname "$0")/k8s-notify-helper.sh"
#
# Provides:
#   K8S_ENV_BADGE   — emoji badge for the context  (e.g. 🔵 🟠 🔴)
#   K8S_ENV_LABEL   — human label                  (e.g. TEST STAGING PROD)
#   k8s_notify      — wrapper around notify-send with env-aware title

# --- Environment detection ---
case "$K8S_CONTEXT" in
*test* | *dev*)
  K8S_ENV_BADGE="🔵"
  K8S_ENV_LABEL="TEST"
  K8S_ENV_HINT="52,101,164" # blue  (RGB for libnotify category hint)
  ;;
*stag* | *staging*)
  K8S_ENV_BADGE="🟠"
  K8S_ENV_LABEL="STAGING"
  K8S_ENV_HINT="245,121,0" # orange
  ;;
*prod* | *production*)
  K8S_ENV_BADGE="🔴"
  K8S_ENV_LABEL="PROD"
  K8S_ENV_HINT="204,0,0" # red
  ;;
*)
  K8S_ENV_BADGE="⚪"
  K8S_ENV_LABEL="UNKNOWN"
  K8S_ENV_HINT="136,138,133" # grey
  ;;
esac

# --- Notification wrapper ---
# Usage:
#   k8s_notify --urgency=URGENCY --icon=ICON "Title suffix" "Body"
#
# The full notification title will be:
#   <ENV_BADGE> [ENV_LABEL] <Title suffix>
# e.g.:  🟠 [STAGING] K8s CRITICAL — my-context
#
k8s_notify() {
  local urgency="normal" icon="dialog-information"
  local title="" body=""

  # Parse named flags first, then positional args
  local -a positional=()
  while [[ $# -gt 0 ]]; do
    case "$1" in
    --urgency=*) urgency="${1#--urgency=}" ;;
    --urgency)
      urgency="$2"
      shift
      ;;
    --icon=*) icon="${1#--icon=}" ;;
    --icon)
      icon="$2"
      shift
      ;;
    *) positional+=("$1") ;;
    esac
    shift
  done

  title="${positional[0]:-}"
  body="${positional[1]:-}"

  local full_title="${K8S_ENV_BADGE} [${K8S_ENV_LABEL}] ${title}"

  notify-send \
    --urgency="$urgency" \
    --icon="$icon" \
    --app-name="k8s-monitor" \
    --hint="string:bgcolor:rgb(${K8S_ENV_HINT})" \
    "$full_title" \
    "$body"
}
