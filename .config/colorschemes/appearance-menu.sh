#!/bin/bash

COLORSCHEMES_DIR="$HOME/.config/colorschemes"

# Get current settings
get_current_theme() {
    if [ -f "$COLORSCHEMES_DIR/.current-theme" ]; then
        cat "$COLORSCHEMES_DIR/.current-theme"
    else
        echo "None"
    fi
}

get_current_waybar_layout() {
    if [ -f "$HOME/.config/waybar/.current-layout" ]; then
        cat "$HOME/.config/waybar/.current-layout"
    else
        echo "None"
    fi
}

get_current_decorations() {
    if [ -f "$HOME/.config/hypr/modules/decoration.conf" ]; then
        CURRENT_SOURCE=$(grep -oP 'source\s*=\s*\K.*' "$HOME/.config/hypr/modules/decoration.conf")
        if [ -n "$CURRENT_SOURCE" ]; then
            basename "$CURRENT_SOURCE" .conf
        else
            echo "None"
        fi
    else
        echo "None"
    fi
}

get_current_animations() {
    if [ -f "$HOME/.config/hypr/modules/animation.conf" ]; then
        CURRENT_SOURCE=$(grep -oP 'source\s*=\s*\K.*' "$HOME/.config/hypr/modules/animation.conf")
        if [ -n "$CURRENT_SOURCE" ]; then
            basename "$CURRENT_SOURCE" .conf
        else
            echo "None"
        fi
    else
        echo "None"
    fi
}

# Get all current settings
CURRENT_THEME=$(get_current_theme)
CURRENT_LAYOUT=$(get_current_waybar_layout)
CURRENT_DECORATIONS=$(get_current_decorations)
CURRENT_ANIMATIONS=$(get_current_animations)

# Main appearance menu with current values
main_menu() {
    cat << EOF
󰏘 Theme [$CURRENT_THEME]
󰸉 Wallpaper
 Waybar Layout [$CURRENT_LAYOUT]
󰐗 Decorations [$CURRENT_DECORATIONS]
󰫢 Animations [$CURRENT_ANIMATIONS]
EOF
}

# Show menu
selection=$(main_menu | rofi -dmenu -i -p "Appearance" -theme "~/.config/rofi/themes/minimal.rasi")

# Extract just the menu item (remove the current value in brackets)
item=$(echo "$selection" | sed 's/ \[.*\]$//')

# Handle selection
case "$item" in
    "󰏘 Theme")
        "$COLORSCHEMES_DIR/rofi-launcher.sh"
        ;;
    "󰸉 Wallpaper")
        "$COLORSCHEMES_DIR/wallpaper-selector.sh"
        ;;
    " Waybar Layout")
        ~/.config/rofi/scripts/waybar-layout.sh
        ;;
    "󰐗 Decorations")
        ~/.config/rofi/scripts/decorations.sh
        ;;
    "󰫢 Animations")
        ~/.config/rofi/scripts/animations.sh
        ;;
esac
