#!/bin/bash
# Color codes
GREEN='\033[1;32m'
CYAN='\033[1;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

THEME="$1"
THEME_DIR="$HOME/.config/colorschemes/$THEME"
WALLPAPER_STATE="$HOME/.config/colorschemes/.wallpaper-state"
CURRENT_THEME_FILE="$HOME/.config/colorschemes/.current-theme"

if [ -z "$THEME" ]; then
	echo -e "${YELLOW}Usage: $0 <theme-name>${NC}"
	exit 1
fi

if [ ! -d "$THEME_DIR" ]; then
	echo -e "${YELLOW}Theme '$THEME' does not exist at $THEME_DIR${NC}"
	notify-send "Theme Error" "Theme '$THEME' not found"
	exit 1
fi

echo "$THEME" > "$CURRENT_THEME_FILE"

echo -e "${GREEN}Applying theme: $THEME${NC}\n"
notify-send "Theme Switching" "Applying theme: $THEME" -t 3000

# Function to create symlink safely
link_config() {
	local src="$1"
	local dest="$2"
	local desc="$3"

	if [ -f "$src" ]; then
		echo -e "${CYAN}-> Linking $desc...${NC}"
		mkdir -p "$(dirname "$dest")"
		ln -sf "$src" "$dest"
	else
		echo -e "${YELLOW}-> $desc file not found. Skipping.${NC}"
	fi
}

# Hyprland config
link_config "$THEME_DIR/hypr/colors.conf" "$HOME/.config/hypr/colors/colors.conf" "Hyprland colors"
echo ""

# Waybar style
link_config "$THEME_DIR/waybar/colors.css" "$HOME/.config/waybar/colors/colors.css" "Waybar CSS"
echo -e "${CYAN}-> Restarting Waybar...${NC}"
pkill waybar > /dev/null 2>&1 && ~/.config/waybar/scripts/launch.sh > /dev/null 2>&1 disown
echo ""

notify-send "Theme Applied" "Successfully switched to: $THEME" -t 5000
