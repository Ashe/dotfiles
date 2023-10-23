#!/usr/bin/env sh

# Restart dunst

pkill dunst
sleep 0.1
dunst > /dev/null 2>&1 &

# Test notifcation
dunstify -a "$(hostname)" --icon="$USER_LOGO" -t 5000 "Welcome $USER! "
