#!/bin/bash

ANIMATIONS_DIR="$HOME/.config/hypr/modules/animations"
ACTIVE_CONFIG="$HOME/.config/hypr/modules/animation.conf"

# Check if animations directory exists
if [ ! -d "$ANIMATIONS_DIR" ]; then
    notify-send "Error" "No animation presets found in $ANIMATIONS_DIR" -u critical -t 3000
    exit 1
fi

# Get list of animation presets (exclude animation.conf itself)
mapfile -t presets < <(find "$ANIMATIONS_DIR" -maxdepth 1 -type f -name "*.conf" ! -name "animation.conf" -exec basename {} .conf \; | sort)

if [ ${#presets[@]} -eq 0 ]; then
    notify-send "Error" "No animation presets found in $ANIMATIONS_DIR" -u critical -t 3000
    exit 1
fi

# Get currently active preset
CURRENT_PRESET=""
if [ -f "$ACTIVE_CONFIG" ]; then
    CURRENT_SOURCE=$(grep -oP 'source\s*=\K.*' "$ACTIVE_CONFIG")
    if [ -n "$CURRENT_SOURCE" ]; then
        CURRENT_PRESET=$(basename "$CURRENT_SOURCE" .conf)
    fi
fi

# Build menu with indicator for current preset
menu_options=""
for preset in "${presets[@]}"; do
    if [ "$preset" = "$CURRENT_PRESET" ]; then
        menu_options+="● $preset\n"
    else
        menu_options+="  $preset\n"
    fi
done

# Show rofi menu
selected=$(echo -en "$menu_options" | rofi -dmenu -i -p "Animations" -theme ~/.config/rofi/themes/minimal.rasi)

[ -z "$selected" ] && exit 0

selected=$(echo "$selected" | sed 's/^● //' | sed 's/^  //')

if [ ! -f "$ANIMATIONS_DIR/$selected.conf" ]; then
    notify-send "Error" "Preset not found: $selected" -u critical -t 3000
    exit 1
fi

echo "source = ~/.config/hypr/modules/animations/$selected.conf" > "$ACTIVE_CONFIG"

hyprctl reload

notify-send "Animations Changed" "Applied: $selected" -t 3000
