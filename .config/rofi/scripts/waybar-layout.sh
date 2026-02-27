#!/bin/bash

WAYBAR_LAYOUTS_DIR="$HOME/.config/waybar/layouts"
WAYBAR_CONFIG="$HOME/.config/waybar/config.jsonc"
WAYBAR_STYLE="$HOME/.config/waybar/style.css"
WAYBAR_STATE_FILE="$HOME/.config/waybar/.current-layout"

# Check if layouts directory exists
if [ ! -d "$WAYBAR_LAYOUTS_DIR" ]; then
    notify-send "Error" "Waybar layouts directory not found: $WAYBAR_LAYOUTS_DIR" -u critical
    exit 1
fi

# Get list of layout directories
mapfile -t layouts < <(find "$WAYBAR_LAYOUTS_DIR" -mindepth 1 -maxdepth 1 -type d -exec basename {} \; | sort)

if [ ${#layouts[@]} -eq 0 ]; then
    notify-send "Error" "No Waybar layouts found in $WAYBAR_LAYOUTS_DIR" -u critical
    exit 1
fi

# Get currently active layout
CURRENT_LAYOUT=""
if [ -f "$WAYBAR_STATE_FILE" ]; then
    CURRENT_LAYOUT=$(cat "$WAYBAR_STATE_FILE")
fi

# Build menu with indicator for current layout
menu_options=""
for layout in "${layouts[@]}"; do
    if [ "$layout" = "$CURRENT_LAYOUT" ]; then
        menu_options+="● $layout\n"
    else
        menu_options+="  $layout\n"
    fi
done

# Show rofi menu
selected=$(echo -en "$menu_options" | rofi -dmenu -i -p "Waybar Layout" -theme ~/.config/rofi/themes/minimal.rasi)

# Exit if nothing selected
if [ -z "$selected" ]; then
    exit 0
fi

# Remove indicator if present
selected=$(echo "$selected" | sed 's/^● //' | sed 's/^  //')

# Validate selection
SELECTED_DIR="$WAYBAR_LAYOUTS_DIR/$selected"
if [ ! -d "$SELECTED_DIR" ]; then
    notify-send "Error" "Layout directory not found: $selected" -u critical
    exit 1
fi

# Check if config.jsonc exists
SELECTED_CONFIG="$SELECTED_DIR/config.jsonc"
if [ ! -f "$SELECTED_CONFIG" ]; then
    notify-send "Error" "config.jsonc not found in layout: $selected" -u critical
    exit 1
fi

# Check if style.css exists
SELECTED_STYLE="$SELECTED_DIR/style.css"
if [ ! -f "$SELECTED_STYLE" ]; then
    notify-send "Error" "style.css not found in layout: $selected" -u critical
    exit 1
fi

# Create symlinks to selected layout
ln -sf "$SELECTED_CONFIG" "$WAYBAR_CONFIG"
ln -sf "$SELECTED_STYLE" "$WAYBAR_STYLE"

# Save current layout to state file
echo "$selected" > "$WAYBAR_STATE_FILE"

# Restart Waybar
pkill -x waybar
sleep 0.5
"$HOME/.config/waybar/scripts/launch.sh" &

notify-send "Waybar Layout" "Applied: $selected" -t 3000

