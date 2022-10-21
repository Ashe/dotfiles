#!/bin/sh

# Dotfiles directory
dotfiles="$HOME/.dotfiles"

# Check for unsaved changes in dotfiles directory
if [[ "$(cd $dotfiles; git status --porcelain)" ]]; then

  # Action for opening dotfiles
  Action=$(notify-send "Dotfiles have unsaved changes" \
    "Check if things are stable and commit changes when possible." \
    -u critical \
    --icon="$dotfiles/img/nix-logo.png" \
    --action=Open=Open)

  # Perform different actions if buttons are clicked
  case $Action in
    Open) $TERMINAL $dotfiles ;;
  esac

fi
