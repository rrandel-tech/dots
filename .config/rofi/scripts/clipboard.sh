#!/bin/bash

selection=$(cliphist list | rofi -dmenu -i -p "Clipboard" -theme ~/.config/rofi/themes/minimal.rasi)

[ -z "$selection" ] && exit 0

echo "$selection" | cliphist decode | wl-copy
