#!/usr/bin/env bash

# Get brightness
get_backlight() {
  echo $(brightnessctl -m | cut -d, -f4)
}

get_current() {
  current=$(get_backlight | sed 's/%//')
  echo $current
}

# Notify
notify_user() {
	notify-send -h string:x-canonical-private-synchronous:sys-notify -u low " Brightness $current%"
}

# Change brightness
change_backlight() {
  brightnessctl set "$1" && get_current && notify_user
}

# Execute accordingly
case "$1" in
	"--get")
		get_backlight
		;;
	"--inc")
		change_backlight "+20%"
		;;
	"--dec")
		change_backlight "20%-"
		;;
	*)
		get_backlight
		;;
esac
