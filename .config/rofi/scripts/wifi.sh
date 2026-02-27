#!/bin/bash

# Get unique SSIDs safely (including spaces)
SSID=$(nmcli -t -f SSID,SECURITY,SIGNAL device wifi list \
    | grep -v '^$' \
    | sort -u \
    | rofi -dmenu -p "WiFi" -theme ~/.config/rofi/themes/minimal.rasi \
    | cut -d: -f1)

# Exit if nothing selected
[ -z "$SSID" ] && exit 1

# Check if network is secured
SECURITY=$(nmcli -t -f SSID,SECURITY device wifi list | grep "^$SSID:" | head -n1 | cut -d: -f2)

if [ -n "$SECURITY" ] && [ "$SECURITY" != "--" ]; then
    PASSWORD=$(rofi -dmenu -password -p "Password for $SSID")
    nmcli device wifi connect "$SSID" password "$PASSWORD"
else
    nmcli device wifi connect "$SSID"
fi
