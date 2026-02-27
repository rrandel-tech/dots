#!/usr/bin/env bash

set -e

sleep_short="0.5"
sleep_medium="1"
sleep_long="2"

sleep "$sleep_medium"

# Kill all possible running xdg-desktop-portals
killall -e xdg-desktop-portal-hyprland 2>/dev/null || true
killall -e xdg-desktop-portal-gnome 2>/dev/null || true
killall -e xdg-desktop-portal-kde 2>/dev/null || true
killall -e xdg-desktop-portal-lxqt 2>/dev/null || true
killall -e xdg-desktop-portal-wlr 2>/dev/null || true
killall -e xdg-desktop-portal-gtk 2>/dev/null || true
killall -e xdg-desktop-portal 2>/dev/null || true

# Setup required environment variables
dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=hyprland

# Stop services safely
systemctl --user stop pipewire wireplumber \
    xdg-desktop-portal \
    xdg-desktop-portal-gnome \
    xdg-desktop-portal-kde \
    xdg-desktop-portal-wlr \
    xdg-desktop-portal-hyprland \
    xdg-desktop-portal-gtk 2>/dev/null || true

sleep "$sleep_short"

# Start required services
systemctl --user start pipewire wireplumber
systemctl --user start xdg-desktop-portal-hyprland
systemctl --user start xdg-desktop-portal-gtk
systemctl --user start xdg-desktop-portal

sleep "$sleep_long"

echo "Portals and PipeWire services restarted successfully."