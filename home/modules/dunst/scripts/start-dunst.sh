#!/usr/bin/env sh

# Restart dunst

pkill dunst
sleep 0.1
dunst > /dev/null 2>&1 &
