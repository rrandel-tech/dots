#!/bin/bash

step=5          # Change amount
min=5           # Minimum brightness
max=100         # Maximum brightness

# Get current brightness (number only)
get_backlight() {
    brightnessctl -m | cut -d, -f4 | tr -d '%'
}

# Send notification
notify_user() {
    notify-send -e \
        -h string:x-canonical-private-synchronous:osd \
        -u low \
        "Brightness" "${1}%"
}

# Set brightness safely
set_backlight() {
    local new=$1

    # Clamp value
    (( new < min )) && new=$min
    (( new > max )) && new=$max

    brightnessctl set "${new}%"
    notify_user "$new"
}

# Main logic
case "$1" in
    --inc)
        current=$(get_backlight)
        set_backlight $((current + step))
        ;;
    --dec)
        current=$(get_backlight)
        set_backlight $((current - step))
        ;;
    --get)
        get_backlight
        ;;
    *)
        get_backlight
        ;;
esac
