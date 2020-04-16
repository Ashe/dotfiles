#!/bin/bash

PDIR="$HOME/.config/polybar"
MONITOR=$(bspc query -M -m --names)
PID=$(grep pid $HOME/.cache/polybar/config_$m.ini | \
  sed 's/.*= \?[a-zA-Z0-9]* \([a-zA-Z0-9]*\).*/\1/')
LAUNCH="polybar-msg -p $PID cmd restart"
 
if  [[ $1 = "-amber" ]]; then
# Replacing colours
sed -i -e 's/bg = .*/bg = #252525/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/fg = .*/fg = #f5f5f5/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/ac = .*/ac = #ffb300/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/bi = .*/bi = #ffb300/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/be = .*/be = #ffb300/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/mf = .*/mf = #f5f5f5/g' $HOME/.cache/polybar/config_$MONITOR.ini
# Restarting polybar
$LAUNCH &

elif  [[ $1 = "-blue" ]]; then
# Replacing colours
sed -i -e 's/bg = .*/bg = #252525/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/fg = .*/fg = #f5f5f5/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/ac = .*/ac = #1e88e5/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/bi = .*/bi = #1e88e5/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/be = .*/be = #1e88e5/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/mf = .*/mf = #f5f5f5/g' $HOME/.cache/polybar/config_$MONITOR.ini
# Restarting polybar
$LAUNCH &

elif  [[ $1 = "-blue-grey" ]]; then
# Replacing colours
sed -i -e 's/bg = .*/bg = #252525/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/fg = .*/fg = #f5f5f5/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/ac = .*/ac = #546e7a/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/bi = .*/bi = #546e7a/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/be = .*/be = #546e7a/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/mf = .*/mf = #f5f5f5/g' $HOME/.cache/polybar/config_$MONITOR.ini
# Restarting polybar
$LAUNCH &

elif  [[ $1 = "-brown" ]]; then
# Replacing colours
sed -i -e 's/bg = .*/bg = #252525/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/fg = .*/fg = #f5f5f5/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/ac = .*/ac = #6d4c41/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/bi = .*/bi = #6d4c41/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/be = .*/be = #6d4c41/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/mf = .*/mf = #f5f5f5/g' $HOME/.cache/polybar/config_$MONITOR.ini
# Restarting polybar
$LAUNCH &

elif  [[ $1 = "-cyan" ]]; then
# Replacing colours
sed -i -e 's/bg = .*/bg = #252525/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/fg = .*/fg = #f5f5f5/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/ac = .*/ac = #00acc1/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/bi = .*/bi = #00acc1/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/be = .*/be = #00acc1/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/mf = .*/mf = #f5f5f5/g' $HOME/.cache/polybar/config_$MONITOR.ini
# Restarting polybar
$LAUNCH &

elif  [[ $1 = "-deep-orange" ]]; then
# Replacing colours
sed -i -e 's/bg = .*/bg = #252525/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/fg = .*/fg = #f5f5f5/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/ac = .*/ac = #f4511e/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/bi = .*/bi = #f4511e/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/be = .*/be = #f4511e/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/mf = .*/mf = #f5f5f5/g' $HOME/.cache/polybar/config_$MONITOR.ini
# Restarting polybar
$LAUNCH &

elif  [[ $1 = "-deep-purple" ]]; then
# Replacing colours
sed -i -e 's/bg = .*/bg = #252525/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/fg = .*/fg = #f5f5f5/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/ac = .*/ac = #5e35b1/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/bi = .*/bi = #5e35b1/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/be = .*/be = #5e35b1/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/mf = .*/mf = #f5f5f5/g' $HOME/.cache/polybar/config_$MONITOR.ini
# Restarting polybar
$LAUNCH &

elif  [[ $1 = "-green" ]]; then
# Replacing colours
sed -i -e 's/bg = .*/bg = #252525/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/fg = .*/fg = #f5f5f5/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/ac = .*/ac = #43a047/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/bi = .*/bi = #43a047/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/be = .*/be = #43a047/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/mf = .*/mf = #f5f5f5/g' $HOME/.cache/polybar/config_$MONITOR.ini
# Restarting polybar
$LAUNCH &

elif  [[ $1 = "-grey" ]]; then
# Replacing colours
sed -i -e 's/bg = .*/bg = #252525/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/fg = .*/fg = #f5f5f5/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/ac = .*/ac = #757575/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/bi = .*/bi = #757575/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/be = .*/be = #757575/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/mf = .*/mf = #f5f5f5/g' $HOME/.cache/polybar/config_$MONITOR.ini
# Restarting polybar
$LAUNCH &

elif  [[ $1 = "-indigo" ]]; then
# Replacing colours
sed -i -e 's/bg = .*/bg = #252525/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/fg = .*/fg = #f5f5f5/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/ac = .*/ac = #3949ab/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/bi = .*/bi = #3949ab/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/be = .*/be = #3949ab/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/mf = .*/mf = #f5f5f5/g' $HOME/.cache/polybar/config_$MONITOR.ini
# Restarting polybar
$LAUNCH &

elif  [[ $1 = "-light-blue" ]]; then
# Replacing colours
sed -i -e 's/bg = .*/bg = #252525/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/fg = .*/fg = #f5f5f5/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/ac = .*/ac = #039be5/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/bi = .*/bi = #039be5/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/be = .*/be = #039be5/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/mf = .*/mf = #f5f5f5/g' $HOME/.cache/polybar/config_$MONITOR.ini
# Restarting polybar
$LAUNCH &

elif  [[ $1 = "-light-green" ]]; then
# Replacing colours
sed -i -e 's/bg = .*/bg = #252525/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/fg = .*/fg = #f5f5f5/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/ac = .*/ac = #7cb342/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/bi = .*/bi = #7cb342/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/be = .*/be = #7cb342/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/mf = .*/mf = #f5f5f5/g' $HOME/.cache/polybar/config_$MONITOR.ini
# Restarting polybar
$LAUNCH &

elif  [[ $1 = "-lime" ]]; then
# Replacing colours
sed -i -e 's/bg = .*/bg = #252525/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/fg = .*/fg = #f5f5f5/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/ac = .*/ac = #c0ca33/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/bi = .*/bi = #c0ca33/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/be = .*/be = #c0ca33/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/mf = .*/mf = #252525/g' $HOME/.cache/polybar/config_$MONITOR.ini
# Restarting polybar
$LAUNCH &

elif  [[ $1 = "-orange" ]]; then
# Replacing colours
sed -i -e 's/bg = .*/bg = #252525/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/fg = .*/fg = #f5f5f5/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/ac = .*/ac = #fb8c00/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/bi = .*/bi = #fb8c00/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/be = .*/be = #fb8c00/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/mf = .*/mf = #f5f5f5/g' $HOME/.cache/polybar/config_$MONITOR.ini
# Restarting polybar
$LAUNCH &

elif  [[ $1 = "-pink" ]]; then
# Replacing colours
sed -i -e 's/bg = .*/bg = #252525/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/fg = .*/fg = #f5f5f5/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/ac = .*/ac = #d81b60/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/bi = .*/bi = #d81b60/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/be = .*/be = #d81b60/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/mf = .*/mf = #f5f5f5/g' $HOME/.cache/polybar/config_$MONITOR.ini
# Restarting polybar
$LAUNCH &

elif  [[ $1 = "-purple" ]]; then
# Replacing colours
sed -i -e 's/bg = .*/bg = #252525/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/fg = .*/fg = #f5f5f5/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/ac = .*/ac = #8e24aa/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/bi = .*/bi = #8e24aa/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/be = .*/be = #8e24aa/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/mf = .*/mf = #f5f5f5/g' $HOME/.cache/polybar/config_$MONITOR.ini
# Restarting polybar
$LAUNCH &

elif  [[ $1 = "-red" ]]; then
# Replacing colours
sed -i -e 's/bg = .*/bg = #252525/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/fg = .*/fg = #f5f5f5/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/ac = .*/ac = #e53935/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/bi = .*/bi = #e53935/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/be = .*/be = #e53935/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/mf = .*/mf = #f5f5f5/g' $HOME/.cache/polybar/config_$MONITOR.ini
# Restarting polybar
$LAUNCH &

elif  [[ $1 = "-teal" ]]; then
# Replacing colours
sed -i -e 's/bg = .*/bg = #252525/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/fg = .*/fg = #f5f5f5/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/ac = .*/ac = #00897b/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/bi = .*/bi = #00897b/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/be = .*/be = #00897b/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/mf = .*/mf = #f5f5f5/g' $HOME/.cache/polybar/config_$MONITOR.ini
# Restarting polybar
$LAUNCH &

elif  [[ $1 = "-yellow" ]]; then
# Replacing colours
sed -i -e 's/bg = .*/bg = #252525/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/fg = .*/fg = #f5f5f5/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/ac = .*/ac = #fdd835/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/bi = .*/bi = #fdd835/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/be = .*/be = #fdd835/g' $HOME/.cache/polybar/config_$MONITOR.ini
sed -i -e 's/mf = .*/mf = #252525/g' $HOME/.cache/polybar/config_$MONITOR.ini
# Restarting polybar
$LAUNCH &

else
echo "Available options:
-amber		-blue			-blue-grey		-brown
-cyan		-deep-orange		-deep-purple		-green
-grey		-indigo			-light-blue		-light-green
-lime		-orange			-pink			-purple
-red		-teal			-yellow"
fi
