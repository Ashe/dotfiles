#!/usr/bin/env sh

rofi_config="~/.config/rofi/config.rasi"

# Rofi action

case $1 in
    d)  r_mode="drun" ;;
    w)  r_mode="window" ;;
    f)  r_mode="filebrowser" ;;
    h)  echo -e "rofilaunch.sh [action]\nwhere action,"
        echo "d :  drun mode"
        echo "w :  window mode"
        echo "f :  filebrowser mode,"
        exit 0 ;;
    *)  r_mode="drun" ;;
esac


# TODO: Fix this
# # Read hypr theme border
#
# wind_border=$(( hypr_border * 3 ))
# elem_border=`[ $hypr_border -eq 0 ] && echo "10" || echo $(( hypr_border * 2 ))`
# r_override="window {border: ${hypr_width}px; border-radius: ${wind_border}px;} element {border-radius: ${elem_border}px;}"
#
#
# # Read hypr font size
#
# fnt_override=`gsettings get org.gnome.desktop.interface font-name | awk '{gsub(/'\''/,""); print $NF}'`
# fnt_override="configuration {font: \"JetBrainsMono Nerd Font ${fnt_override}\";}"
#
#
# # Read hypr theme icon
#
# icon_override=`gsettings get org.gnome.desktop.interface icon-theme | sed "s/'//g"`
# icon_override="configuration {icon-theme: \"${icon_override}\";}"
#
#
# # Launch rofi
#
# rofi -show $r_mode -theme-str "${fnt_override}" -theme-str "${r_override}" -theme-str "${icon_override}" -config "${roconf}"

# TODO: Remove this
rofi -show $r_mode -config "${rofi_config}"
