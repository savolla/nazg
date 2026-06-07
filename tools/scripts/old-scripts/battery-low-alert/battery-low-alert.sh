#                          _
#__      ____ _ _ __ _ __ (_)_ __   __ _
#\ \ /\ / / _` | '__| '_ \| | '_ \ / _` |
# \ V  V / (_| | |  | | | | | | | | (_| |
#  \_/\_/ \__,_|_|  |_| |_|_|_| |_|\__, |
#                                  |___/
#-----------------------------------------------
# Before using this script please make sure that
# you have "acpi" and "mpv" utilities installed.
#-----------------------------------------------

# An experimental "Battery Low for i3" warning script written by savolla.
# This script is actually created mostly for i3 users.
# As we know that i3 does not warn us on low battery levels and this
# causes a lot of problems sometimes. This also works on tty terminals withou X
# if you use ssh or something. I hope this script will help you to solve those
# problems :)
# you can customize things at VARIABLES section. Set your personal
# wave, mp3 file to play when your battery decreases to $CURRENT_BATTERY_VALUE
# you can also use commands like i3-nagbar instead of ringing a sound or even espeak :D
# If you want to find more sounds go to https://freesound.org
# make it run at startup and enjoy! don't let you data being lost :)


#                  _   _
# _ __ _   _ _ __ | |_(_)_ __ ___   ___
#| '__| | | | '_ \| __| | '_ ` _ \ / _ \
#| |  | |_| | | | | |_| | | | | | |  __/
#|_|   \__,_|_| |_|\__|_|_| |_| |_|\___|

#!/bin/bash
while true;
do
sleep 60

#                 _       _     _
#__   ____ _ _ __(_) __ _| |__ | | ___  ___
#\ \ / / _` | '__| |/ _` | '_ \| |/ _ \/ __|
# \ V / (_| | |  | | (_| | |_) | |  __/\__ \
#  \_/ \__,_|_|  |_|\__,_|_.__/|_|\___||___/

CURRENT_STATUS_OF_BATTERY=`acpi --battery | awk '{print $3}' | sed s/,//g`              # Usually "Charging" of "Discharging"
CURRENT_BATTERY_VALUE=`acpi --battery | awk '{print $4}' | sed s/%,//g`                 # Persentage of your remaining battery value
AVARAGE=15                                                                             # You will hear warning under this value
ALERT_SOUND="/home/savolla/src/scripts/battery-low-alert/alert-sounds/beep-2.wav" # The sound that you will hear. Change it dude ;D



    if [ $CURRENT_STATUS_OF_BATTERY == "Charging" ];
    then
    continue

    else if [ $CURRENT_BATTERY_VALUE -lt $AVARAGE ];
    then

       while true;
       do
           CURRENT_STATUS_OF_BATTERY=`acpi --battery | awk '{print $3}' | sed s/,//g`
           sleep 1
           if [ $CURRENT_STATUS_OF_BATTERY == "Charging" ];
           then
               break
           else
               mpv $ALERT_SOUND 2> /dev/null
			   sleep 5
           fi
       done

    fi
    fi
done

