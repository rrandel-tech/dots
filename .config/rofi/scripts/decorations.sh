#!/bin/bash

DECORATIONS_DIR="$HOME/.config/hypr/modules/decorations"
ACTIVE_CONFIG="$HOME/.config/hypr/modules/decoration.conf"

# Check if decorations directory exists
if [ ! -d "$DECORATIONS_DIR" ]; then
    notify-send "Error" "No decoration presets found in $DECORATIONS_DIR" -u critical -t 3000
    exit 1
fi

# Get list of decoration presets (exclude decoration.conf itself)
mapfile -t presets < <(find "$DECORATIONS_DIR" -maxdepth 1 -type f -name "*.conf" ! -name "decorations.conf" -exec basename {} .conf \; | sort)

if [ ${#presets[@]} -eq 0 ]; then
    notify-send "Error" "No decoration presets found in $DECORATIONS_DIR" -u critical -t 300
    exit 1
fi

# Get currently active preset
CURRENT_PRESET=""
if [ -f  "$ACTIVE_CONFIG" ]; then
    # Extract the filename from the source line
    CURRENT_SOURCE=$(grep -oP 'source\s*=\K.*' "$ACTIVE_CONFIG")
    if [ -n "$CURRENT_SOURCE" ]; then
        # Get just the filename without path and extension
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
selected=$(echo -en "$menu_options" | rofi -dmenu -i -p "Decorations" -theme ~/.config/rofi/themes/minimal.rasi)

# Exit if nothing selected
if [ -z "$selected" ]; then
    exit 0
fi

# Remove indicator if present
selected=$(echo "$selected" | sed 's/^● //' | sed 's/^  //')

# Validate selection
if [ ! -f "$DECORATIONS_DIR/$selected.conf" ]; then
    notify-send "Error" "No decoration presets found: $selected" -u critical -t 3000
    exit 1
fi

# Update the decorations.conf file to source the selected preset
echo "source = ~/.config/hypr/modules/decorations/$selected.conf" > "$ACTIVE_CONFIG"

# Reload Hyprland
hyprctl reload

notify-send "Decorations Changed" "Applied: $selected" -t 3000