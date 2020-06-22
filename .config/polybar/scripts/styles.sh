#!/bin/sh

## Setup variables
monitor=$(bspc query -M -m --names)
polybar_path="$HOME/.cache/polybar/config_$monitor.ini"
polybar_theme=$(grep theme $polybar_path | \
  sed 's/.*= \?[a-zA-Z0-9]* \([a-zA-Z0-9]*\).*/\1/')
polybar_pid=$(grep pid $polybar_path | \
  sed 's/.*= \?[a-zA-Z0-9]* \([a-zA-Z0-9]*\).*/\1/')
rofi_path="$HOME/.config/polybar/scripts/themes"

## Change from light to dark
if  [[ $polybar_theme = "light" ]]; then

  sed -i -e "s/theme = .*/theme = dark/g" $polybar_path

  sed -i -e 's/bg = .*/bg = #212B30/g' $polybar_path
  sed -i -e 's/bg-alt = .*/bg-alt = #5C6F7B/g' $polybar_path
  sed -i -e 's/fg = .*/fg = #C4C7C5/g' $polybar_path
  sed -i -e 's/ac = .*/ac = #4DD0E1/g' $polybar_path

  sed -i -e 's/red = .*/red = #EC7875/g' $polybar_path
  sed -i -e 's/pink = .*/pink = #EC407A/g' $polybar_path
  sed -i -e 's/purple = .*/purple = #BA68C8/g' $polybar_path
  sed -i -e 's/blue = .*/blue = #42A5F5/g' $polybar_path
  sed -i -e 's/cyan = .*/cyan = #4DD0E1/g' $polybar_path
  sed -i -e 's/teal = .*/teal = #00B19F/g' $polybar_path
  sed -i -e 's/green = .*/green = #61C766/g' $polybar_path
  sed -i -e 's/lime = .*/lime = #B9C244/g' $polybar_path
  sed -i -e 's/yellow = .*/yellow = #FDD835/g' $polybar_path
  sed -i -e 's/amber = .*/amber = #FBC02D/g' $polybar_path
  sed -i -e 's/orange = .*/orange = #E57C46/g' $polybar_path
  sed -i -e 's/brown = .*/brown = #AC8476/g' $polybar_path
  sed -i -e 's/indigo = .*/indigo = #6C77BB/g' $polybar_path

## Change from dark to light
elif  [[ $polybar_theme = "dark" ]]; then

  sed -i -e "s/theme = .*/theme = light/g" $polybar_path

  sed -i -e 's/bg = .*/bg = #FFFFFF/g' $polybar_path
  sed -i -e 's/bg-alt = .*/bg-alt = #CACACA/g' $polybar_path
  sed -i -e 's/fg = .*/fg = #555555/g' $polybar_path
  sed -i -e 's/ac = .*/ac = #4DA8B9/g' $polybar_path

  sed -i -e 's/red = .*/red = #F06A6A/g' $polybar_path
  sed -i -e 's/pink = .*/pink = #EC1850/g' $polybar_path
  sed -i -e 's/purple = .*/purple = #BA40A0/g' $polybar_path
  sed -i -e 's/blue = .*/blue = #427DCD/g' $polybar_path
  sed -i -e 's/cyan = .*/cyan = #4DA8B9/g' $polybar_path
  sed -i -e 's/teal = .*/teal = #008978/g' $polybar_path
  sed -i -e 's/green = .*/green = #5CAC30/g' $polybar_path
  sed -i -e 's/lime = .*/lime = #B9A41C/g' $polybar_path
  sed -i -e 's/yellow = .*/yellow = #D2A91D/g' $polybar_path
  sed -i -e 's/amber = .*/amber = #FD890F/g' $polybar_path
  sed -i -e 's/orange = .*/orange = #EA7222/g' $polybar_path
  sed -i -e 's/brown = .*/brown = #AC5C4E/g' $polybar_path
  sed -i -e 's/indigo = .*/indigo = #4759C6/g' $polybar_path
fi

# Relaunch this bar
polybar-msg -p $polybar_pid cmd restart
