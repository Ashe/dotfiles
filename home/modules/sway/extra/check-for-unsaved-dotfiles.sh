#!/usr/bin/env sh

# Dotfiles directory
dotfiles="$HOME/.dotfiles"

# Check for unsaved changes in dotfiles directory
if [[ "$(cd $dotfiles; git status --porcelain)" ]]; then

  # Action for opening dotfiles
  notify-send "Dotfiles have unsaved changes" \
    "Check if things are stable and commit changes when possible." \
    -u critical \
    --icon="$dotfiles/img/nix-logo.png"
fi
