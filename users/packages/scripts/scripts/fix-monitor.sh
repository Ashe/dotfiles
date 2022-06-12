#!/bin/sh

cat /home/ashe/.config/sway/extra/MYEDID >/sys/kernel/debug/dri/0/DP-1/edid_override && echo 1 >/sys/kernel/debug/dri/0/DP-1/trigger_hotplug
