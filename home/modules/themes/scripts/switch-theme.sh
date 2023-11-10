#!/usr/bin/env sh

# Set variables
ScrDir=`dirname $(realpath $0)`
source ${ScrDir}/global-control.sh


# Evaluate options
while getopts "npsti" option ; do
  case $option in

  n ) # Set next theme
    current_theme=`head -1 $ThemeCtl | cut -d '|' -f 2` #default value
    flg=0
    while read line
    do
      if [ $flg -eq 1 ] ; then
        current_theme=`echo $line | cut -d '|' -f 2`
        break
      elif [ `echo $line | cut -d '|' -f 1` -eq 1 ] ; then
        flg=1
      fi
    done < $ThemeCtl
    export xtrans="grow" ;;

  p ) # Set previous theme
    current_theme=`tail -1 $ThemeCtl | cut -d '|' -f 2` #default value
    flg=0
    while read line
    do
      if [ $flg -eq 1 ] ; then
        current_theme=`echo $line | cut -d '|' -f 2`
        break
      elif [ `echo $line | cut -d '|' -f 1` -eq 1 ] ; then
        flg=1
      fi
    done < <( tac $ThemeCtl )
    export xtrans="outer" ;;

  s ) # Set selected theme
    shift $((OPTIND -1))
    current_theme=$1 ;;

  t ) # Display tooltip
    echo ""
    echo "󰆊 Next/Previous Theme"
    exit 0 ;;

  i ) # Don't restart window manager
    ignore_restart=1 ;;

  * ) # Invalid option
    echo "n : Set next theme"
    echo "p : Set previous theme"
    echo "s : Set theme from parameter"
    echo "t : Display tooltip"
    echo "i : Ignore window-manager restart"
    exit 1 ;;
  esac
done


# Update theme control
if [ `cat $ThemeCtl | awk -F '|' -v thm=$current_theme '{if($2==thm) print$2}' | wc -w` -ne 1 ] ; then
  echo "Unknown theme selected: $current_theme"
  echo "Available themes are:"
  cat $ThemeCtl | cut -d '|' -f 2
  exit 1
else
  echo "Selected theme: $current_theme"
  sed -i "s/^1/0/g" $ThemeCtl
  awk -F '|' -v thm=$current_theme '{OFS=FS} {if($2==thm) $1=1; print$0}' $ThemeCtl > "$cache_dir/tmp" && mv "$cache_dir/tmp" $ThemeCtl
fi


# Ensure variables are correct
source ${ScrDir}/global-control.sh


# Swwwallpaper
getWall=`grep '^1|' $ThemeCtl | cut -d '|' -f 3`
getWall=`eval echo $getWall`
getName=`basename $getWall`
ln -fs $getWall $ThemeDir/wall.set
ln -fs $cache_dir/${current_theme}/${getName}.rofi $ThemeDir/wall.rofi
ln -fs $cache_dir/${current_theme}/${getName}.blur $ThemeDir/wall.blur
${ScrDir}/switch-wallpaper.sh

if [ $? -ne 0 ] ; then
  echo "ERROR: Unable to set wallpaper"
  exit 1
fi


# Gtk3
gtk_dir="$ConfDir/gtk-3.0/"
gtk_theme=$(lookup_theme_data "$current_theme" 2)
if [ -e "$gtk_dir/base_settings.ini" ] && [ -n "$gtk_theme" ] && [ -n "$icon_theme" ]; then
  # @TODO: Prefer dark?
  cat "$gtk_dir/base_settings.ini" > "$gtk_dir/settings.ini"
  echo "gtk-theme-name=${gtk_theme}" >> "$gtk_dir/settings.ini"
  echo "gtk-icon-theme-name=${icon_theme}" >> "$gtk_dir/settings.ini"
  # Flatpak GTK
  if command -v flatpak &>/dev/null; then
    flatpak --user override --env=GTK_THEME="${gtk_theme}"
    flatpak --user override --env=ICON_THEME="${icon_theme}"
  fi
fi


# Qt5ct
qt_dir="$ConfDir/qt5ct/"
if [ -e "$qt_dir/base_qt5ct.conf" ] && [ -n "$icon_theme" ]; then
  cat "$qt_dir/base_qt5ct.conf" > "$qt_dir/qt5ct.conf"
  echo "" >> "$qt_dir/qt5ct.conf"
  echo "[Appearance]" >> "$qt_dir/qt5ct.conf"
  echo "color_scheme_path=$ThemeDir/config/qt5ct/${current_theme}.conf" >> "$qt_dir/qt5ct.conf"
  echo "icon_theme=$icon_theme" >> "$qt_dir/qt5ct.conf"
  echo "custom_palette=true" >> "$qt_dir/qt5ct.conf"
  echo "standard_dialogs=default" >> "$qt_dir/qt5ct.conf"
  echo "style=kvantum" >> "$qt_dir/qt5ct.conf"
fi


# Kvantum
if command -v kvantummanager &>/dev/null; then
  kvantummanager --set ${current_theme}
fi


# Waybar
if command -v waybar &>/dev/null; then
  ln -fs $ThemeDir/config/css/${current_theme}.css $ConfDir/waybar/theme.css
fi


# Rofi
if command -v rofi &>/dev/null; then
  ln -fs $ThemeDir/config/rofi/${current_theme}.rasi $ThemeDir/rofi.rasi
fi


# Dunst
if command -v dunst &>/dev/null; then
  cat "$ConfDir/dunst/base_dunstrc" | envsubst > "$ConfDir/dunst/dunstrc"
  echo "" >> "$ConfDir/dunst/dunstrc"
  cat "$ThemeDir/config/dunst/${current_theme}" | envsubst >> "$ConfDir/dunst/dunstrc"
fi


# wlogout
if command -v wlogout &>/dev/null; then
  ln -fs $ThemeDir/config/css/${current_theme}.css $ConfDir/wlogout/theme.css
fi


# Kitty
if command -v kitty &>/dev/null; then
  ln -fs $ThemeDir/config/kitty/${current_theme}.conf $ThemeDir/kitty.conf
  pkill kitty --signal SIGUSR1
fi


# VS Code
if command -v code &>/dev/null; then
  vs_code_dir="$ConfDir/Code/User"
  vs_code_theme=$(lookup_theme_data "$current_theme" 4)
  if [ -e "$vs_code_dir/base_settings.json" ] && [ -n "$vs_code_theme" ]; then
    cat "$vs_code_dir/base_settings.json" | head -n -1 > "$vs_code_dir/settings.json"
    echo "  \"workbench.colorTheme\": \"${vs_code_theme}\"," >> "$vs_code_dir/settings.json"
    echo "}" >> "$vs_code_dir/settings.json"
  fi
fi


# Hyprland
if command -v hyprctl &>/dev/null; then
  ln -fs $ThemeDir/config/hyprland/${current_theme}.conf $ThemeDir/hyprland.conf
  if [ -z $ignore_restart ]; then
    hyprctl reload
  fi
fi

# Send notification if not restarting
if [ -z $ignore_restart ]; then
  notify-send --icon="$getWall" -t 5000 "Theme" "$current_theme"
fi
