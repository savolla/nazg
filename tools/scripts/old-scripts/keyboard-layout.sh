#!/bin/bash

######################### Prepare the Environment ###########################
SCRIPT_DEPENDENCIES=(xmodmap setxkbmap)

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

remapControlKeys() {
	xmodmap -e "keycode 108 = Escape"	
	xmodmap -e "keycode 66 = ISO_Level3_Shift"	
	xmodmap -e "keycode 50 = Alt_L"	
	xmodmap -e "keycode 64 = Shift_L"	
}

CHOICES="tr\nru\nus\ndefault"
CHOSEN=$(echo -e $CHOICES | dmenu -i)

case "$CHOSEN" in
	tr)
		setxkbmap tr
		# # # remapControlKeys
		;;
	ru) 	
		setxkbmap ru 
		remapControlKeys
		;;
	us) 	
		setxkbmap us
		remapControlKeys
		;;
	default)
		setxkbmap tr
		;;
	*)
		echo -n "unknown"
		;;
esac
