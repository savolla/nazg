#!/bin/bash
######################### Prepare the Environment ###########################
SCRIPT_DEPENDENCIES=(zathura rofi xargs)

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
            install $(pkgfile $1 | head -n 1)
        fi
    done
}

checkDependencies $SCRIPT_DEPENCENCIES
#############################################################################
READER="zathura"
$READER "$(find ~/lib/* -type f -name '*.pdf' -o -name '*.epub' \
 | awk -F "/" '{ print $NF }' \
 | rofi -dmenu -i -p "Select Book: " \
 | xargs -d'\n' find ~/lib/* -iname )"
