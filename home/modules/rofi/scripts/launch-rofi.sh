#!/usr/bin/env sh

rofi_config="~/.config/rofi/config.rasi"

# Launch rofi

rofi -config "${rofi_config}" "$@"
