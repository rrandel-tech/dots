#!/bin/bash

KEYBINDS_JSON="$HOME/.config/rofi/scripts/keybindings.json"

if [ ! -f "$KEYBINDS_JSON" ]; then
    notify-send "Error" "keybindings.json not found" -u critical
    exit 1
fi

# Parse JSON and format with column alignment
format_keybinds() {
    jq -r '
        to_entries[] |
        "━━━━ \(.key | ascii_upcase) ━━━━" as $header |
        ($header, (.value | to_entries[] | "\(.key)|→|\(.value)"))
    ' "$KEYBINDS_JSON" | \
    awk -F'|' '{
        if (NF == 3) {
            printf "  %-30s %s  %s\n", $1, $2, $3
        } else {
            print $0
        }
    }' | sed '1{/^$/d;}' | head -n -1
}

# Show in rofi
format_keybinds | rofi -dmenu -i -p "Keybindings Reference" -nocustom -theme ~/.config/rofi/themes/minimal.rasi