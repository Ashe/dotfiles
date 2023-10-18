#!/usr/bin/env sh

# Configuration directory
ConfDir="$HOME/.config"
ThemeDir="$ConfDir/themes"
mkdir -p $ThemeDir

# Ensure that themes can be switched
source $ThemeDir/scripts/initialise.sh

# Wallpaper var
EnableWallDcol=0
ThemeCtl="$control_file"
CacheDir="$HOME/.cache/themes"
mkdir -p $CacheDir

# Theme var
gtkTheme=`gsettings get org.gnome.desktop.interface gtk-theme | sed "s/'//g"`
gtkMode=`gsettings get org.gnome.desktop.interface color-scheme | sed "s/'//g" | awk -F '-' '{print $2}'`

# Hypr var
hypr_border=`hyprctl -j getoption decoration:rounding | jq '.int'`
hypr_width=`hyprctl -j getoption general:border_size | jq '.int'`
