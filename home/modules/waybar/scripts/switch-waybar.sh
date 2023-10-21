#!/usr/bin/env sh

# Setup paths

configs_dir="$HOME/.config/waybar/configs"
config_path="$HOME/.config/waybar/config.jsonc"
modules_path="$HOME/.config/waybar/modules.jsonc"


# Define functions

Find_First_Config()
{
  first_config_path=$(find "$configs_dir/" -type f -print -quit)
  if [[ -n "$first_config_path" ]]; then
    current_config=$(basename "$first_config_path" .jsonc)
  else
    echo "Couldn't initialise new config file - no configs found in '$configs_dir'."
    exit 1
  fi
}

Regenerate_Config()
{
  echo "Generating config: '$current_config'."
  local current_config_path="$configs_dir/$current_config.jsonc"
  if [ -f "$current_config_path" ]; then
    echo "//$current_config" > "$config_path"
    echo "{" >> "$config_path"
    sed '1d;$d' "$current_config_path" | envsubst >> "$config_path"
    sed '1d;$d' "$modules_path" | envsubst >> "$config_path"
    echo "}" >> "$config_path"
  else
    if [ -z "$1" ]; then
      echo "Couldn't regenerate config - current config not found: '$current_config_path'."
      echo "Attempting to fall back to different config.."
      Find_First_Config
      Regenerate_Config 1
    else
      echo "Failed to regenerate config '$current_config'."
      exit 1
    fi
  fi
}

Config_Change()
{
  local current_config_path="$configs_dir/$current_config.jsonc"
  if [ -f "$current_config_path" ]; then

    local config_files=("$configs_dir"/*.jsonc)
    local num_configs=${#config_files[@]}
    declare -A index_array
    for i in "${!config_files[@]}"; do
      local file="${config_files[i]}"
      local filename=$(basename "$file")
      index_array["$filename"]=$i
    done

    current_config_basename=$(basename "$current_config_path")
    local index="${index_array[$current_config_basename]}"
    if [ -n "$index" ]; then

      local dir=0
      if [ "$1" = "n" ]; then
        index=$((index + 1))
      elif [ "$1" = "p" ]; then
        index=$((index - 1))
      fi

      if [ $index -lt 0 ]; then
        index=$((num_configs - 1))
      elif [ $index -ge $num_configs ]; then
        index=0
      fi

      local new_config="${config_files[$index]}"
      if [ -n "$new_config" ]; then
        current_config=$(basename "$new_config" .jsonc)
      fi
    else
      echo "Couldn't find current config amongst config files."
      echo "Current config name: '$current_config_basename'."
      echo "Available configs: '${config_files[@]}'."
      exit 1
    fi
  else
    echo "Couldn't switch config - current config file not found: '$current_config_path'."
    exit 1
  fi
}


# Environment substitutions

export set_sysname=`hostnamectl hostname`
y_monres=`cat /sys/class/drm/*/modes | head -1 | cut -d 'x' -f 2`
export w_height=$(( y_monres*2/100 ))
export i_size="12"
export i_task="16"
theme_control="$HOME/.config/themes/scripts/global-control.sh"
if [ -f "$theme_control" ]; then
  source "$theme_control"
  export i_theme=$icon_theme
fi


# Ensure a theme is set

if [ ! -f "$HOME/.config/waybar/theme.css" ]; then
  theme_switch="$HOME/.config/themes/scripts/switch-theme.sh"
  if [ -f "$theme_switch" ]; then
    sh "$theme_switch"
  fi
fi


# Check if we already have a current configuration

if [ -f "$config_path" ]; then
  first_line=$(head -n 1 "$config_path")
  if [[ -n "$first_line" ]]; then
    found_config=$(echo "$first_line" | awk '{print $1}' | sed 's|//||')
    if [ -f "$configs_dir/$found_config.jsonc" ]; then
      current_config=$found_config
    fi
  fi
fi


# If we don't have a configuration, find the first one available

if [ -z "$current_config" ]; then
  Find_First_Config
fi


# Handle arguments

while getopts "nps" option ; do
  case $option in
    n ) # Set next config
      Config_Change n ;;
    p ) # Set previous config
      Config_Change p ;;
    s ) # Set input config
      shift $((OPTIND -1))
      if [ -f "$configs_dir/$1.jsonc" ] ; then
        current_config=$1
      fi ;;
    * ) # Invalid option
      echo "n : Set next config"
      echo "p : Set previous config"
      echo "s : Set config from parameter"
      exit 1 ;;
  esac
done


# Generate new config after changes made

Regenerate_Config


# Restart waybar

pkill waybar
waybar > /dev/null 2>&1 &
