#!/usr/bin/env bash

# Starts a scan of available broadcasting SSIDs
nmcli dev wifi rescan

FIELDS=SSID,SECURITY,BARS
THEME="$HOME/.config/rofi/network.rasi"
goback=" Back"

LIST=$(nmcli --fields "$FIELDS" device wifi list | sed '/^--/d' | tail -n +2)
# For some reason rofi always approximates character width 2 short... hmmm
RWIDTH=$(($(echo "$LIST" | head -n 1 | awk '{print length($0); }')+2))
# Dynamically change the height of the rofi menu
LINENUM=$(echo "$LIST" | wc -l)
# Gives a list of known connections so we can parse it later
KNOWNCON=$(nmcli connection show)
# Really janky way of telling if there is currently a connection
CONSTATE=$(nmcli -fields WIFI g)

CURRSSID=$(nmcli -t -f active,ssid dev wifi | awk -F: '$1 ~ /^yes/ {print $2}')

# If there are more than 8 SSIDs, the menu will still only have 8 lines
if [ "$LINENUM" -gt 8 ] && [[ "$CONSTATE" =~ "enabled" ]]; then
	LINENUM=8
elif [[ "$CONSTATE" =~ "disabled" ]]; then
	LINENUM=1
fi


if [[ "$CONSTATE" =~ "enabled" ]]; then
	TOGGLE="󰤨  Wi-Fi: ON"
elif [[ "$CONSTATE" =~ "disabled" ]]; then
	TOGGLE="󰤮  Wi-Fi: OFF"
fi

CHENTRY=$(echo -e "$LIST\n$TOGGLE\n󰌘  Manual" | uniq -u | rofi -dmenu -p "  Wi-Fi " -lines "$LINENUM" -theme $THEME)
#echo "$CHENTRY"
CHSSID=$(echo "$CHENTRY" | sed  's/\s\{2,\}/\|/g' | awk -F "|" '{print $1}')
echo "selected $CHSSID"
echo "current $CURRSSID"

# If the user inputs "manual" as their SSID in the start window, it will bring them to this screen
if [ "$CHENTRY" = "󰌘  Manual" ] ; then
	# Manual entry of the SSID and password (if appplicable)
	MSSID=$(echo "Enter the SSID of the Network (SSID,password)" | rofi -dmenu -p "Network " -lines 1 -theme $THEME)
	# Separating the password from the entered string
	MPASS=$(echo "$MSSID" | awk -F "," '{print $2}')

	#echo "$MSSID"
	#echo "$MPASS"

	# If the user entered a manual password, then use the password nmcli command
	if [ "$MPASS" = "" ]; then
		nmcli dev wifi con "$MSSID"
	else
		nmcli dev wifi con "$MSSID" password "$MPASS"
	fi

elif [ "$CHENTRY" = "󰤮  Wi-Fi: OFF" ]; then
	nmcli radio wifi on
elif [ "$CHENTRY" = "󰤨  Wi-Fi: ON" ]; then
	nmcli radio wifi off
else
	if [ "$CHSSID" = "$CURRSSID" ]; then
		nmcli con up "$CHSSID"
		if [ $? -eq 0 ]; then
        		exit 0    
		fi
	elif [[ $(echo "$KNOWNCON" | grep "$CHSSID" | awk '{print $1}') = $(echo "$CHSSID" | awk '{print $1}') ]]; then
		nmcli con up "$CHSSID"
		if [ $? -eq 0 ]; then
			exit 0
		else
			nmcli connection delete "$CHSSID"
			if [[ "$CHENTRY" =~ "WPA2" ]] || [[ "$CHENTRY" =~ "WEP" ]]; then
			WIFIPASS=$(rofi -dmenu -p "Password " -lines 1 -theme $THEME)
			fi
			nmcli dev wifi con "$CHSSID" password "$WIFIPASS"
		fi
	else
		if [[ "$CHENTRY" =~ "WPA2" ]] || [[ "$CHENTRY" =~ "WEP" ]]; then
			WIFIPASS=$(rofi -dmenu -p "Password " -lines 1 -theme $THEME)
		fi
		nmcli dev wifi con "$CHSSID" password "$WIFIPASS"
	fi
fi
