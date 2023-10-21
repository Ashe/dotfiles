#!/usr/bin/env sh


# Convenience function to lookup names for theme data
lookup_theme_data() {
  local search_string="$1"
  local field_number="$2"
  awk -v search="$search_string" -F '|' '$1 == search { print $'"$field_number"' }' "$ThemeData"
}


# Configuration directory
ConfDir="$HOME/.config"
ThemeDir="$ConfDir/themes"
mkdir -p $ThemeDir

# Ensure that themes can be switched
source $ThemeDir/scripts/initialise.sh

# Wallpaper var
ThemeCtl="$control_file"
ThemeData="$ThemeDir/theme-data.conf"
cache_dir="$HOME/.cache/themes"
mkdir -p $cache_dir


current_theme=$(grep '^1|' $ThemeCtl | awk -F '|' '{print $2}')
icon_theme=$(lookup_theme_data "$current_theme" 3)
gtk_theme=$(lookup_theme_data "$current_theme" 2)


# Hypr var
hypr_border=`hyprctl -j getoption decoration:rounding | jq '.int'`
hypr_width=`hyprctl -j getoption general:border_size | jq '.int'`
