#!/bin/bash
######################### Prepare the Environment ###########################
SCRIPT_DEPENDENCIES=(xrandr dmenu pacmd )

isInstalled() {
	which $1
}

install() {
	sudo pacman -S $1 --noconfirm
}

checkDependencies() {
	for i in ${SCRIPT_DEPS[@]} # for every program in SCRIPT_DEPENDENCIES
	do
		isInstalled $i
		if [[ $? -ne 0 ]] # if not installed
		then
            install $(pkgfile $1)
		fi
	done
}

checkDependencies $SCRIPT_DEPENCENCIES
#############################################################################

INTERNAL_OUTPUT="$(xrandr | grep " connected" | cut -f1 -d " " | head -n 1)"
# PREFERED_FONT="Input"

# choices will be displayed in dmenu
choices="laptop\ndual\nexternal\nclone"

# Your choice in dmenu will determine what xrandr command to run
# chosen=$(echo -e $choices | dmenu -i -l 4 -w 250 -y 20 -fn $PREFERED_FONT)
chosen=$(echo -e $choices | dmenu -i )

# detect connected display type
if [ `xrandr | grep VGA-1  | grep -c ' connected '` -eq 1 ];
then
	EXTERNAL_OUTPUT="VGA-1"
fi
if [ `xrandr | grep DVI-1  | grep -c ' connected '` -eq 1 ];
then
	EXTERNAL_OUTPUT="DVI-1"
fi
if [ `xrandr | grep HDMI-1 | grep -c ' connected '` -eq 1 ];
then
	EXTERNAL_OUTPUT="HDMI-1"
fi
if [ `xrandr | grep HDMI-2 | grep -c ' connected '` -eq 1 ];
then
	EXTERNAL_OUTPUT="HDMI-2"
fi
if [ `xrandr | grep HDMI-3 | grep -c ' connected '` -eq 1 ];
then
	EXTERNAL_OUTPUT="HDMI-3"
fi
if [ `xrandr | grep DP1    | grep -c ' connected '` -eq 1 ];
then
	EXTERNAL_OUTPUT="DP-1"
fi
if [ `xrandr | grep DP-2   | grep -c ' connected '` -eq 1 ];
then
	EXTERNAL_OUTPUT="DP-2"
fi
if [ `xrandr | grep DP-3   | grep -c ' connected '` -eq 1 ];
then
	EXTERNAL_OUTPUT="DP-3"
fi

# set display and switch sound
case $chosen in
	external) xrandr --output $INTERNAL_OUTPUT --off --output $EXTERNAL_OUTPUT --auto --primary
			  pacmd set-card-profile 0 "output:hdmi-stereo+input:analog-stereo"
			  ;;
	laptop)
			xrandr --output $INTERNAL_OUTPUT --auto --primary --output $EXTERNAL_OUTPUT --off
			pacmd set-card-profile 0 "output:analog-stereo+input:analog-stereo"
			;;
	clone)
			xrandr --output $INTERNAL_OUTPUT --auto --output $EXTERNAL_OUTPUT --auto --same-as $INTERNAL_OUTPUT
			pacmd set-card-profile 0 "output:hdmi-stereo+input:analog-stereo"
			;;
	dual)
			xrandr --output $INTERNAL_OUTPUT --auto --output $EXTERNAL_OUTPUT --auto --right-of $INTERNAL_OUTPUT --primary
			pacmd set-card-profile 0 "output:analog-stereo+input:analog-stereo"
			;;
	*)
			echo -e error
			;;
esac
