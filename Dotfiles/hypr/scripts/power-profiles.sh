#!/bin/bash

# Define the available power profiles
profiles=("󰥱  Balanced" "󰠠  Performance" "󱤅  Power Saver")

# Use Rofi to display the available options and capture the chosen profile
chosen=$(printf "%s\n" "${profiles[@]}" | rofi -dmenu -p "Power Profile" -theme "~/.config/rofi/power-profiles.rasi" )

# Check if the user made a selection
if [ -n "$chosen" ]; then
    case "$chosen" in
        "󰥱  Balanced")
            powerprofilesctl set balanced
            notify-send "Balanced Power Profile"
            ;;
        "󰠠  Performance")
            powerprofilesctl set performance
            notify-send "Performance Power Profile"
            ;;
        "󱤅  Power Saver")
            powerprofilesctl set power-saver
            notify-send "Power Saver Power Profile"
            ;;
        *)
            ;;
    esac
fi
