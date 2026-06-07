#!/usr/bin/env bash

# Define color temperature values for each time of day
MORNING_TEMP=5000
MIDDAY_TEMP=4500
EVENING_TEMP=4000
NIGHT_TEMP=3000

# Define transition step size and time interval
TRANSITION_STEP=50
TRANSITION_INTERVAL=5 # seconds

# Function to determine the current season
get_season() {
  local month=$(date +%m)
  case $month in
  12 | 1 | 2) echo "Winter" ;;
  3 | 4 | 5) echo "Spring" ;;
  6 | 7 | 8) echo "Summer" ;;
  9 | 10 | 11) echo "Autumn" ;;
  *) echo "Unknown" ;;
  esac
}

# Function to smoothly transition screen temperature
smooth_transition() {
  local current_temp=$1
  local target_temp=$2
  local step=$3
  local interval=$4

  if ((current_temp < target_temp)); then
    while ((current_temp < target_temp)); do
      current_temp=$((current_temp + step))
      xsct "$current_temp"
      sleep $interval
    done
  elif ((current_temp > target_temp)); then
    while ((current_temp > target_temp)); do
      current_temp=$((current_temp - step))
      xsct "$current_temp"
      sleep $interval
    done
  fi
}

# Function to set screen temperature based on time of day and season
set_screen_temp() {
  local hour=$(date +%H)
  local season=$(get_season)
  local temp

  case $hour in
  [0-5] | 2[3-4])
    temp=$NIGHT_TEMP
    ;;
  [6-9])
    temp=$MORNING_TEMP
    ;;
  1[0-5])
    temp=$MIDDAY_TEMP
    ;;
  1[6-8])
    temp=$EVENING_TEMP
    ;;
  *)
    temp=$NIGHT_TEMP
    ;;
  esac

  if [ "$season" == "Winter" ]; then
    temp=$((temp - 500))
  elif [ "$season" == "Summer" ]; then
    temp=$((temp + 500))
  fi

  if [ -z "$INITIAL_SET" ]; then
    xsct "$temp"
    echo "Set screen temperature to $temp K"
    INITIAL_SET=true
  else
    smooth_transition "$(xsct | awk '{ print $5 }')" "$temp" "$TRANSITION_STEP" "$TRANSITION_INTERVAL"
    echo "Set screen temperature to $temp K"
  fi
}

# Loop to continuously set screen temperature
while true; do
  set_screen_temp
  sleep 10m
done
