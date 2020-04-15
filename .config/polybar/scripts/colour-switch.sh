#!/bin/bash

SDIR="$HOME/.config/polybar/scripts"

MENU="$(rofi -sep "|" -dmenu -i -p 'Select' \
  -location 3 -columns 1 -xoffset -240 -yoffset 52 \
  -width 12 -hide-scrollbar -line-padding 4 \
  -padding 20 -lines 10 \
  <<< "\
   amber|\
   blue|\
   blue-grey|\
   brown|\
   cyan|\
   deep-orange|\
   deep-purple|\
   green|\
   grey|\
   indigo|\
   light-blue|\
   light-green|\
   lime|\
   orange|\
   pink|\
   purple|\
   red|\
   teal|\
   yellow|\
   amber-dark|\
   blue-dark|\
   blue-grey-dark|\
   brown-dark|\
   cyan-dark|\
   deep-orange-dark|\
   deep-purple-dark|\
   green-dark|\
   grey-dark|\
   indigo-dark|\
   light-blue-dark|\
   light-green-dark|\
   lime-dark|\
   orange-dark|\
   pink-dark|\
   purple-dark|\
   red-dark|\
   teal-dark|\
   yellow-dark")"
  case "$MENU" in
    ## Light Colors
    *amber) $SDIR/colours-light.sh -amber ;;
    *blue) $SDIR/colours-light.sh -blue ;;
    *blue-grey) $SDIR/colours-light.sh -blue-grey ;;
    *brown) $SDIR/colours-light.sh -brown ;;
    *cyan) $SDIR/colours-light.sh -cyan ;;
    *deep-orange) $SDIR/colours-light.sh -deep-orange ;;
    *deep-purple) $SDIR/colours-light.sh -deep-purple ;;
    *green) $SDIR/colours-light.sh -green ;;
    *grey) $SDIR/colours-light.sh -grey ;;
    *indigo) $SDIR/colours-light.sh -indigo ;;
    *light-blue) $SDIR/colours-light.sh -light-blue ;;
    *light-green) $SDIR/colours-light.sh -light-green ;;
    *lime) $SDIR/colours-light.sh -lime ;;
    *orange) $SDIR/colours-light.sh -orange ;;
    *pink) $SDIR/colours-light.sh -pink ;;
    *purple) $SDIR/colours-light.sh -purple ;;
    *red) $SDIR/colours-light.sh -red ;;
    *teal) $SDIR/colours-light.sh -teal ;;
    *yellow) $SDIR/colours-light.sh -yellow ;;
    ## Dark Colors
    *amber-dark) $SDIR/colours-dark.sh -amber ;;
    *blue-dark) $SDIR/colours-dark.sh -blue ;;
    *blue-grey-dark) $SDIR/colours-dark.sh -blue-grey ;;
    *brown-dark) $SDIR/colours-dark.sh -brown ;;
    *cyan-dark) $SDIR/colours-dark.sh -cyan ;;
    *deep-orange-dark) $SDIR/colours-dark.sh -deep-orange ;;
    *deep-purple-dark) $SDIR/colours-dark.sh -deep-purple ;;
    *green-dark) $SDIR/colours-dark.sh -green ;;
    *grey-dark) $SDIR/colours-dark.sh -grey ;;
    *indigo-dark) $SDIR/colours-dark.sh -indigo ;;
    *light-blue-dark) $SDIR/colours-dark.sh -light-blue ;;
    *light-green-dark) $SDIR/colours-dark.sh -light-green ;;
    *lime-dark) $SDIR/colours-dark.sh -lime ;;
    *orange-dark) $SDIR/colours-dark.sh -orange ;;
    *pink-dark) $SDIR/colours-dark.sh -pink ;;
    *purple-dark) $SDIR/colours-dark.sh -purple ;;
    *red-dark) $SDIR/colours-dark.sh -red ;;
    *teal-dark) $SDIR/colours-dark.sh -teal ;;
    *yellow-dark) $SDIR/colours-dark.sh -yellow				
  esac
