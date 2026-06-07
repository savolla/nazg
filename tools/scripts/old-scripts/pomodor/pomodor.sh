#!/bin/sh

# "DATE","TIME","WORK_TIME","REST_TIME","POMODOROS","TOPIC","TOTAL_WORKED_TIME"
LOG_FILE="./my-pomodoro-log.csv"
CURRENT_DATE=$(date "+%d.%m.%Y")
CURRENT_TIME=$(date "+%T")
WORK_TIME=$((25*60)) # 25 mins
REST_TIME=$((5*60)) # 5 mins
POMODOROS=1
TOTAL_WORKED_TIME=$((($work_time+$rest_time)*$pomodoros))



# printf "%s,%s,%s,%s,%s,%s" "$CURRENT_DATE" "$CURRENT_TIME"
printf "%s, %s\n" "$CURRENT_DATE" "$CURRENT_TIME" >> $LOG_FILE 






