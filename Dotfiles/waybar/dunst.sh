#!/usr/bin/env bash
set -euo pipefail

readonly ENABLED='<big></big>'
readonly DISABLED='<big></big>'
dbus-monitor path='/org/freedesktop/Notifications',interface='org.freedesktop.DBus.Properties',member='PropertiesChanged' --profile |
  while read -r _; do
    PAUSED="$(dunstctl is-paused)"
    if [ "$PAUSED" == 'false' ]; then
      CLASS="enabled"
      TEXT="$ENABLED"
    else
      CLASS="disabled"
      TEXT="$DISABLED"
      COUNT="$(dunstctl count waiting)"
      if [ "$COUNT" != '0' ]; then
        TEXT="$DISABLED"
      fi
    fi
    printf '%s\n' "$TEXT" 
  done
