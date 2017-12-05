#!/bin/sh

# Use 'arandr' for generating these settings easily.
# Dotfiles use 'default.sh` to load desktop settings

# Desktop settings, 3 monitors with a 1440p 165hz monitor in the middle of two 1080p's.
xrandr --output DP-3 --off --output DVI-I-0 --off --output HDMI-0 --mode 1920x1080 --pos 4480x512 --rotate normal --output DP-5 --mode 1920x1080 --pos 0x512 --rotate normal --output DP-4 --off --output DVI-I-1 --off --output DP-2 --primary --mode 2560x1440 --rate 165 --pos 1920x0 --rotate normal --output DP-1 --off --output DP-0 --off
