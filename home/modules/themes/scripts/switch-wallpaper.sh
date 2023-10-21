#!/usr/bin/env sh

# Set variables
ScrDir=`dirname $(realpath $0)`
source ${ScrDir}/global-control.sh


# Define functions

Wall_Update()
{
  local x_wall=$1
  local x_update=${x_wall/$HOME/"~"}
  cacheImg=`echo $x_wall | awk -F '/' '{print $NF}'`

  if [ ! -d ${cache_dir}/${curTheme} ] ; then
    mkdir -p ${cache_dir}/${curTheme}
  fi

  if [ ! -f "${cache_dir}/${curTheme}/${cacheImg}" ] ; then
    convert -strip $x_wall -thumbnail 500x500^ -gravity center -extent 500x500 ${cache_dir}/${curTheme}/${cacheImg}
  fi

  if [ ! -f "${cache_dir}/${curTheme}/${cacheImg}.rofi" ] ; then
    #convert -strip -resize 1000 -unsharp 0x1+1.0+0 $x_wall ${cache_dir}/${curTheme}/rofi.${cacheImg}
    convert -strip -resize 2000 -gravity center -extent 2000 -quality 90 $x_wall ${cache_dir}/${curTheme}/${cacheImg}.rofi
  fi

  if [ ! -f "${cache_dir}/${curTheme}/${cacheImg}.blur" ] ; then
    convert -strip -scale 10% -blur 0x3 -resize 100% $x_wall ${cache_dir}/${curTheme}/${cacheImg}.blur
  fi

  sed -i "/^1|/c\1|${curTheme}|${x_update}" $ctlFile
  ln -fs $x_wall $wallSet
  ln -fs ${cache_dir}/${curTheme}/${cacheImg}.rofi $wallRfi
  ln -fs ${cache_dir}/${curTheme}/${cacheImg}.blur $wallBlr
}

Wall_Change()
{
  local x_switch=$1

  for (( i=0 ; i<${#Wallist[@]} ; i++ ))
  do
    if [ ${Wallist[i]} == ${fullPath} ] ; then

      if [ $x_switch == 'n' ] ; then
        nextIndex=$(( (i + 1) % ${#Wallist[@]} ))
      elif [ $x_switch == 'p' ] ; then
        nextIndex=$(( i - 1 ))
      fi

      Wall_Update ${Wallist[nextIndex]}
      break
    fi
  done
}

Wall_Set()
{
  if [ -z $xtrans ] ; then
    xtrans="grow"
  fi

  swww img $wallSet \
    --transition-bezier .43,1.19,1,.4 \
    --transition-type $xtrans \
    --transition-duration 0.7 \
    --transition-fps 60 \
    --invert-y \
    --transition-pos "$( hyprctl cursorpos )"
}


# Set variables

ScrDir=`dirname $(realpath $0)`
source $ScrDir/global-control.sh
ctlFile="$ThemeCtl"
wallSet="$ThemeDir/wallpapers/wall.set"
wallBlr="$ThemeDir/wallpapers/wall.blur"
wallRfi="$ThemeDir/wallpapers/wall.rofi"
ctlLine=`grep '^1|' $ctlFile`

if [  `echo $ctlLine | wc -w` -ne "1" ] ; then
  echo "ERROR : $ctlFile Unable to fetch theme..."
  exit 1
fi

curTheme=`echo $ctlLine | cut -d '|' -f 2`
fullPath=`echo $ctlLine | cut -d '|' -f 3`
fullPath=`eval echo $fullPath`
wallName=`echo $fullPath | awk -F '/' '{print $NF}'`
wallPath=`echo $fullPath | sed "s/\/$wallName//g"`

if [ ! -f  $wallPath/$wallName ] ; then
  if [ -d $ThemeDir/wallpapers/$curTheme ] ; then
    wallPath="$ThemeDir/wallpapers/$curTheme"
    fullPath=`ls $wallPath/* | head -1`
  else
    echo "ERROR: wallpaper $wallPath/$wallName not found..."
    exit 1
  fi
fi

Wallist=(`ls $wallPath/*`)


# Evaluate options

while getopts "nps" option ; do
  case $option in
    n ) # Set next wallpaper
      xtrans="grow"
      Wall_Change n ;;
    p ) # Set previous wallpaper
      xtrans="outer"
      Wall_Change p ;;
    s ) # Set input wallpaper
      shift $((OPTIND -1))
      if [ -f $1 ] ; then
        Wall_Update $1
      fi ;;
    * ) # Invalid option
      echo "n : set next wall"
      echo "p : set previous wall"
      echo "s : set input wallpaper"
      exit 1 ;;
  esac
done


# Check swww daemon and set wall

swww query
if [ $? -eq 1 ] ; then
  swww init
fi


if [ "$#" -eq 0 ]; then
  Wall_Update $fullPath
fi

Wall_Set
