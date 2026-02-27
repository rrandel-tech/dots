#!/usr/bin/env bash

kitty --hold -e bash -c "
sudo pacman -Syu
pkill -SIGRTMIN+8 waybar
"