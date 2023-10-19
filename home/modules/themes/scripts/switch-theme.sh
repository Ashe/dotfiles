#!/usr/bin/env sh

# Set variables
ScrDir=`dirname $(realpath $0)`
source ${ScrDir}/global-control.sh


# Evaluate options
while getopts "npst" option ; do
  case $option in

  n ) # Set next theme
    ThemeSet=`head -1 $ThemeCtl | cut -d '|' -f 2` #default value
    flg=0
    while read line
    do
      if [ $flg -eq 1 ] ; then
        ThemeSet=`echo $line | cut -d '|' -f 2`
        break
      elif [ `echo $line | cut -d '|' -f 1` -eq 1 ] ; then
        flg=1
      fi
    done < $ThemeCtl
    export xtrans="grow" ;;

  p ) # Set previous theme
    ThemeSet=`tail -1 $ThemeCtl | cut -d '|' -f 2` #default value
    flg=0
    while read line
    do
      if [ $flg -eq 1 ] ; then
        ThemeSet=`echo $line | cut -d '|' -f 2`
        break
      elif [ `echo $line | cut -d '|' -f 1` -eq 1 ] ; then
        flg=1
      fi
    done < <( tac $ThemeCtl )
    export xtrans="outer" ;;

  s ) # Set selected theme
    shift $((OPTIND -1))
    ThemeSet=$1 ;;

  t ) # Display tooltip
    echo ""
    echo "󰆊 Next/Previous Theme"
    exit 0 ;;

  * ) # Invalid option
    echo "n : set next theme"
    echo "p : set previous theme"
    echo "s : set theme from parameter"
    echo "t : display tooltip"
    exit 1 ;;
  esac
done


# Update theme control
if [ `cat $ThemeCtl | awk -F '|' -v thm=$ThemeSet '{if($2==thm) print$2}' | wc -w` -ne 1 ] ; then
  echo "Unknown theme selected: $ThemeSet"
  echo "Available themes are:"
  cat $ThemeCtl | cut -d '|' -f 2
  exit 1
else
  echo "Selected theme: $ThemeSet"
  sed -i "s/^1/0/g" $ThemeCtl
  awk -F '|' -v thm=$ThemeSet '{OFS=FS} {if($2==thm) $1=1; print$0}' $ThemeCtl > "$CacheDir/tmp" && mv "$CacheDir/tmp" $ThemeCtl
fi


# Convenience function to lookup names for theme data
lookup_theme_data() {
  local search_string="$1"
  local field_number="$2"
  awk -v search="$search_string" -F '|' '$1 == search { print $'"$field_number"' }' "$ThemeData"
}


# Swwwallpaper
getWall=`grep '^1|' $ThemeCtl | cut -d '|' -f 3`
getWall=`eval echo $getWall`
getName=`basename $getWall`
mkdir -p "$ConfDir/swww"
ln -fs $getWall $ConfDir/swww/wall.set
ln -fs $CacheDir/${ThemeSet}/${getName}.rofi $ConfDir/swww/wall.rofi
ln -fs $CacheDir/${ThemeSet}/${getName}.blur $ConfDir/swww/wall.blur
${ScrDir}/switch-wallpaper.sh

if [ $? -ne 0 ] ; then
  echo "ERROR: Unable to set wallpaper"
  exit 1
fi


# Icons
icon_theme=$(lookup_theme_data "$ThemeSet" 3)


# Gtk3
gtk_theme=$(lookup_theme_data "$ThemeSet" 2)
if [ -n "$gtk_theme" ] && [ -n "$icon_theme" ]; then
  cat "$ConfDir/gtk-3.0/base_settings.ini" > "$ConfDir/gtk-3.0/settings.ini"
  echo "gtk-theme-name=${gtk_theme}" >> "$ConfDir/gtk-3.0/settings.ini"
  echo "gtk-icon-theme-name=${icon_theme}" >> "$ConfDir/gtk-3.0/settings.ini"
  # Flatpak GTK
  if command -v flatpak &>/dev/null; then
    flatpak --user override --env=GTK_THEME="${gtk_theme}"
    flatpak --user override --env=ICON_THEME="${icon_theme}"
  fi
fi


# Hyprland
if command -v hyprctl &>/dev/null; then
  ln -fs $ThemeDir/config/hyprland/${ThemeSet}.conf $ThemeDir/hyprland.conf
  hyprctl reload
fi


# Kitty
if command -v kitty &>/dev/null; then
  ln -fs $ThemeDir/config/kitty/${ThemeSet}.conf $ThemeDir/kitty.conf
  pkill kitty --signal SIGUSR1
fi


# VS Code
if command -v code &>/dev/null; then
  vs_code_theme=$(lookup_theme_data "$ThemeSet" 4)
  if [ -n "$vs_code_theme" ]; then
    cat "$ConfDir/Code/User/base_settings.json" | head -n -1 > "$ConfDir/Code/User/settings.json"
    echo "  \"workbench.colorTheme\": \"${vs_code_theme}\"," >> "$ConfDir/Code/User/settings.json"
    echo "}" >> "$ConfDir/Code/User/settings.json"
  fi
fi


# @TODO: Finish this

# # Qt5ct
# sed -i "/^color_scheme_path=/c\color_scheme_path=$ConfDir/qt5ct/colors/${ThemeSet}.conf" $ConfDir/qt5ct/qt5ct.conf
# sed -i "/^icon_theme=/c\icon_theme=${IconSet}" $ConfDir/qt5ct/qt5ct.conf
#
#
#
#
#
#
# # Rofi & Waybar
# ${ScrDir}/swwwallbash.sh $getWall
