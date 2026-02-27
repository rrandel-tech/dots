#!/bin/bash

# ---------- Volume helpers ----------
get_default_sink() {
    pactl info | grep "Default Sink" | awk '{print $3}'
}

get_volume_num() {
    local sink
    sink=$(get_default_sink)
    pactl get-sink-volume "$sink" | awk '{print int($5)}'  # e.g., "50%"
}

is_muted() {
    local sink
    sink=$(get_default_sink)
    pactl get-sink-mute "$sink" | grep -q yes
}

get_volume_label() {
    if is_muted; then
        printf "Muted"
    else
        printf "%s%%" "$(get_volume_num)"
    fi
}

notify_user() {
    local val label
    if is_muted; then
        val=0
    else
        val="$(get_volume_num)"
    fi
    label="$(get_volume_label)"

    notify-send -e \
      -h int:value:"$val" \
      -h string:x-canonical-private-synchronous:volume_notif \
      -u low \
      "Volume" "$label"
}

# ---------- Volume controls ----------
inc_volume() {
    local sink
    sink=$(get_default_sink)
    pactl set-sink-volume "$sink" +5%
    notify_user
}

dec_volume() {
    local sink
    sink=$(get_default_sink)
    pactl set-sink-volume "$sink" -5%
    notify_user
}

toggle_mute() {
    local sink
    sink=$(get_default_sink)
    pactl set-sink-mute "$sink" toggle
    notify_user
}

# ---------- Microphone helpers ----------
get_default_source() {
    pactl info | grep "Default Source" | awk '{print $3}'
}

get_mic_num() {
    local src
    src=$(get_default_source)
    pactl get-source-volume "$src" | awk '{print int($5)}'
}

is_mic_muted() {
    local src
    src=$(get_default_source)
    pactl get-source-mute "$src" | grep -q yes
}

get_mic_label() {
    if is_mic_muted; then
        printf "Muted"
    else
        printf "%s%%" "$(get_mic_num)"
    fi
}

notify_mic_user() {
    local val label
    if is_mic_muted; then
        val=0
    else
        val="$(get_mic_num)"
    fi
    label="$(get_mic_label)"

    notify-send -e \
      -h int:value:"$val" \
      -h string:x-canonical-private-synchronous:mic_notif \
      -u low \
      "Microphone" "$label"
}

# ---------- Microphone controls ----------
toggle_mic() {
    local src
    src=$(get_default_source)
    pactl set-source-mute "$src" toggle
    notify_mic_user
}

inc_mic_volume() {
    local src
    src=$(get_default_source)
    pactl set-source-volume "$src" +5%
    notify_mic_user
}

dec_mic_volume() {
    local src
    src=$(get_default_source)
    pactl set-source-volume "$src" -5%
    notify_mic_user
}

# ---------- CLI ----------
case "$1" in
  --get)        get_volume_label ;;
  --inc)        inc_volume ;;
  --dec)        dec_volume ;;
  --toggle)     toggle_mute ;;
  --toggle-mic) toggle_mic ;;
  --mic-inc)    inc_mic_volume ;;
  --mic-dec)    dec_mic_volume ;;
  *)            get_volume_label ;;
esac
