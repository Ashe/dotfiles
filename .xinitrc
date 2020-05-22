#!/bin/sh

userresources=$HOME/.Xresources
usermodmap=$HOME/.Xmodmap
sysresources=/etc/X11/xinit/.Xresources
sysmodmap=/etc/X11/xinit/.Xmodmap

# Merge in system resources
if [ -f $sysresources ]; then
  xrdb -merge $sysresources
fi

# Merge system defaults
if [ -f $sysmodmap ]; then
  xmodmap $sysmodmap
fi

# Merge user resources
if [ -f "$userresources" ]; then
  xrdb -merge "$userresources"
fi

# Merge user defaults
if [ -f "$usermodmap" ]; then
  xmodmap "$usermodmap"
fi

# Start programs
if [ -d /etc/X11/xinit/xinitrc.d ] ; then
  for f in /etc/X11/xinit/xinitrc.d/?*.sh ; do
    [ -x "$f" ] && . "$f"
  done
  unset f
fi

# Fix Java programs
wmname compiz
export AWT_TOOLKIT=MToolkit

# Start window manager (sxhkd is started there)
exec bspwm
