#!/bin/bash
grep '^bindsym' /home/"$USER"/.config/i3/config | sed 's/$mod2/ALT/' | sed 's/$mod/WIN/' | sed 's/bindsym//' | sed 's/exec //' | sed 's/--no-startup-id //' | sed 's/#.*$//' | sed 's/--release //g' | sort | bat
