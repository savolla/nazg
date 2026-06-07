#!/bin/bash
echo -e "starting bluetooth "
systemctl start bluetooth.service
blueman-applet &
bluetooth on
blueman-manager &
