#!/bin/sh

# Location of screenshots taken
dir="$XDG_PICTURES_DIR/Screenshots"
filename=$(date +"%d-%m-%Y_%T.png")

# Ensure screenshot directory exists
mkdir -p "$dir"

# Take screenshot and save as file
file=$(grimshot save $1 "$dir/$filename")

# If screenshot was saved to a file successfully
if [ -n "$file" ]; then

  # Copy the screenshot to clipboard
  wl-copy -t image/png < "$file"

  # Print to terminal
  echo "Screenshot captured and saved to $dir/$file."

  # Send notification that the screenshot was successfully taken
  Action=$(notify-send "Screenshot captured" "Saved to $dir" \
    --icon="$file" \
    --action=Open=Open \
    --action=Copy=Copy)

  # Perform different actions if buttons are clicked
  case $Action in
    Open) $FILEGUI $file ;;
    Copy) wl-copy -t image/png < "$file" ;;
  esac
fi
