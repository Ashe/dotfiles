#!/usr/bin/env sh

# Destination of the control file
control_file="$HOME/.config/themes/theme.ctl"

# Check if the destination file exists
if [ ! -f "$control_file" ]; then

  # Create the file
  touch "$control_file"

  # Initialize the line counter
  first_line=true

  # Iterate over subdirectories in $HOME/.config/themes/wallpapers
  for theme_dir in "$HOME/.config/themes/wallpapers"/*; do

    # If the directory exists
    if [ -d "$theme_dir" ] || [ -L "$theme_dir" ]; then

      # Get the first file within the theme subdirectory
      first_file="$(find "$theme_dir/" -maxdepth 1 -type f | head -n 1)"

      # Set the first part of the line (0 or 1)
      if [ "$first_line" = true ]; then
        first_part=1
        first_line=false
      else
        first_part=0
      fi

      # Extract the theme name from the subdirectory name
      theme_name=$(basename "$theme_dir")

      # Append the line to the destination file
      echo "${first_part}|${theme_name}|${first_file}" >> "$control_file"
    fi
  done
fi
