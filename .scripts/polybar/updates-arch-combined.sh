#!/bin/sh

if ! updates_arch=$(checkupdates 2> /dev/null | wc -l ); then
    updates_arch=0
fi

if ! updates_aur=$(yay -Qum 2> /dev/null | wc -l); then
# if ! updates_aur=$(cower -u 2> /dev/null | wc -l); then
# if ! updates_aur=$(trizen -Su --aur --quiet | wc -l); then
    updates_aur=0
fi

totalUpdates=$(("$updates_arch" + "$updates_aur"))

if [ "$totalUpdates" -gt 0 ]; then
    echo -e "$updates_arch \uf01e $updates_aur"
else
    echo ""
fi
