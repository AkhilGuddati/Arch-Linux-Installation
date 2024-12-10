#!/usr/bin/env bash

time=$(date "+%d-%b_%H-%M-%S")
dir="$(xdg-user-dir)/Pictures/Screenshots"
file="Screenshot_${time}.png"
notify_cmd_shot="notify-send -h string:x-canonical-private-synchronous:shot-notify -u low -i "$dir/$file""

notify_view() {
        local check_file="$dir/$file"
        if [[ -e "$check_file" ]]; then
            ${notify_cmd_shot} "Screenshot Saved."
            soundoption="screen-capture.*"
	    userDIR="$HOME/.local/share/sounds"
	    systemDIR="/usr/share/sounds"
	    defaultTheme="freedesktop"
            sound_file=$(find $systemDIR/$defaultTheme/stereo -name "$soundoption" -print -quit)
            if ! test -f "$sound_file"; then
                echo "Error: Sound file not found."
                exit 1
            fi
	    pw-play "$sound_file"
        
    	else
            ${notify_cmd_shot} "Screenshot NOT Saved."
        fi
}

shotarea() {
	grim -g "$(slurp)" - >"$dir/$file"
	notify_view
}

shotarea
