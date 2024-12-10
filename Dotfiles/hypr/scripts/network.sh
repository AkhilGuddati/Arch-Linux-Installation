#!/usr/bin/env bash

# Configuration
FIELDS=SSID,SECURITY,BARS
THEME="$HOME/.config/rofi/network.rasi"
goback=" Back"
MAX_SSIDS=8

# Scan for Wi-Fi networks
scan_wifi() {
    nmcli dev wifi rescan
    LIST=$(nmcli --fields "$FIELDS" device wifi list | sed '/^--/d' | tail -n +2)
}

# Get current connected SSID
get_current_connection() {
    CURRSSID=$(nmcli -t -f active,ssid dev wifi | awk -F: '$1 ~ /^yes/ {print $2}')
}

# Toggle Wi-Fi on or off
toggle_wifi() {
    CONSTATE=$(nmcli -fields WIFI g)

    if [[ "$CONSTATE" =~ "enabled" ]]; then
        TOGGLE="󰤨  Wi-Fi: ON"
    elif [[ "$CONSTATE" =~ "disabled" ]]; then
        TOGGLE="󰤮  Wi-Fi: OFF"
    fi
}

# Calculate number of lines and menu height
calculate_menu_height() {
    LINENUM=$(echo "$LIST" | wc -l)

    if [ "$LINENUM" -gt "$MAX_SSIDS" ] && [[ "$CONSTATE" =~ "enabled" ]]; then
        LINENUM=$MAX_SSIDS
    elif [[ "$CONSTATE" =~ "disabled" ]]; then
        LINENUM=1
    fi
}

# Handle manual network entry
handle_manual_input() {
    MSSID=$(echo -e "$goback" | rofi -dmenu -p "Network" -theme-str 'entry {placeholder: "Enter (SSID, Password)";}' -theme $THEME)
    MPASS=$(echo "$MSSID" | awk -F "," '{print $2}')

    if [ "$MSSID" = "$goback" ]; then
        main_menu
    elif [ -z "$MPASS" ]; then
        nmcli dev wifi con "$MSSID"
        notify-send -h string:x-canonical-private-synchronous:sys-notify -u low "  Connected to Network"
    else
        nmcli dev wifi con "$MSSID" password "$MPASS"
        notify-send -h string:x-canonical-private-synchronous:sys-notify -u low "  Connected to Network"
    fi
}

connect_to_new_network(){
	if [[ "$CHENTRY" =~ "WPA2" ]] || [[ "$CHENTRY" =~ "WEP" ]]; then
		WIFIPASS=$(echo -e $goback |rofi -dmenu -p "Password" -lines 1 -theme $THEME)
        fi
	if [ "$WIFIPASS" = "$goback" ]; then
        	main_menu
	else
        	nmcli dev wifi con "$CHSSID" password "$WIFIPASS"
          notify-send -h string:x-canonical-private-synchronous:sys-notify -u low "  Connected to Network"
	fi
}

# Connect to the selected Wi-Fi network
connect_to_network() {
    CHSSID=$1
    CHENTRY=$2

    if [ "$CHSSID" = "$CURRSSID" ]; then
        nmcli con up "$CHSSID"
        if [ $? -eq 0 ]; then
            exit 0
        fi
    elif [[ $(echo "$KNOWNCON" | grep "$CHSSID" | awk '{print $1}') = $(echo "$CHSSID" | awk '{print $1}') ]]; then
        nmcli con up "$CHSSID"
        notify-send -h string:x-canonical-private-synchronous:sys-notify -u low "  Connected to Network"
        if [ $? -eq 0 ]; then
            exit 0
        else
            nmcli connection delete "$CHSSID"
            connect_to_new_network "$CHSSID" "$CHENTRY"
            notify-send -h string:x-canonical-private-synchronous:sys-notify -u low "  Connected to Network"
        fi
    else
        connect_to_new_network "$CHSSID" "$CHENTRY"
        notify-send -h string:x-canonical-private-synchronous:sys-notify -u low "  Connected to Network"
    fi
}

# Main menu function
main_menu() {
    scan_wifi
    LIST=$(nmcli --fields "$FIELDS" device wifi list | sed '/^--/d' | tail -n +2)
    KNOWNCON=$(nmcli connection show)
    get_current_connection
    toggle_wifi
    calculate_menu_height

    if [ -z "$LIST" ]; then
        CHENTRY=$(echo -e "$TOGGLE\n󰌘  Manual" | rofi -dmenu -p "  Wi-Fi" -lines 2 -theme $THEME)
    else
        CHENTRY=$(echo -e "$LIST\n$TOGGLE\n󰌘  Manual" | uniq -u | rofi -dmenu -p "  Wi-Fi" -lines "$LINENUM" -theme $THEME)
    fi
	
    if [ -z "$CHENTRY" ]; then
        exit 0
    fi

    CHSSID=$(echo "$CHENTRY" | sed 's/\s\{2,\}/\|/g' | awk -F "|" '{print $1}')
    echo "selected $CHSSID"
    echo "current $CURRSSID"

    # Handle different cases for the selected entry
    if [ "$CHENTRY" = "󰌘  Manual" ]; then
        handle_manual_input
    elif [ "$CHENTRY" = "󰤮  Wi-Fi: OFF" ]; then
        nmcli radio wifi on
	main_menu
    elif [ "$CHENTRY" = "󰤨  Wi-Fi: ON" ]; then
        nmcli radio wifi off
	main_menu
    else
        connect_to_network "$CHSSID" "$CHENTRY"
    fi
}

main_menu
