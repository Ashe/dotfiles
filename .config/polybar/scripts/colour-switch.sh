#!/bin/bash

# Change the theme
switch () {
  $HOME/.scripts/change-theme $1
  $HOME/.scripts/restart-window-manager
}

# Show options
MENU="$(rofi -sep "|" -dmenu -i -p 'Select' \
  -location 5 -columns 1 -xoffset -240 -yoffset -52 \
  -width 12 -hide-scrollbar -line-padding 4 \
  -padding 20 -lines 2 \
  <<< " \
     cyberpunk|\
     flowers")"
            case "$MENU" in
				## Light Colors
        *cyberpunk) switch cyberpunk ;;
        *flowers)   switch flowers ;;
            esac
