#!/usr/bin/env bash

# Available themes: alchemy, subtle, ultra_minimal, velvetline

killall -9 waybar
killall -9 swaync

waybar &
swaync &
