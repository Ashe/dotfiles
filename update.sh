#!/bin/sh

# Gets the command name without path
cmd(){ echo `basename $0`; }

# Help command output
usage(){
echo "\
`cmd` [ OPTION... ]
Will update both system and user configurations by default
-h, --help;       Show this prompt
-s, --system;     Update and rebuild system configuration
-u, --user;       Update and rebuild user configuration
-r, --rebuild;    Rebuild both system and user configurations
--rebuild-system; Rebuild system configuration without updating
--rebuild-user;   Rebuild user configuration without updating
"
}

# Error message
error(){
    if [ "$#" -gt 1 ] 
    then
      echo "`cmd`: illegal number of parameters"
    else
      echo "`cmd`: invalid option -- '$1'"
    fi
    echo "Try '`cmd` -h' for more information.";
    exit 1;
}

# Rebuild system configuration
rebuild_system_config()
{
  # Update system flake.lock
  if [ "$1" == "--update" ]
  then
    echo -e "\nUpdating system flake.lock.."
    (cd system/; sudo nix flake update)
  fi

  # Rebuild system configuration
  echo -e "\nRebuilding system configuration.."
  sudo nixos-rebuild switch --flake './system#nixos'
}

# Rebuild user configuration
rebuild_user_config()
{
  # Update user flake.lock
  if [ "$1" == "--update" ]
  then
    echo -e "\nUpdating user flake.lock.."
    (cd users/; nix flake update)
  fi

  # Rebuild user configuration
  echo -e "\nRebuilding user configuration.."
  nix run home-manager --no-write-lock-file -- switch --flake "./users#nixos"
}

# Operate inside the dotfiles directory
cd ~/.dotfiles/

# Parse commands
if [ "$#" -gt 1 ]
then 
  error $@
elif [ "$#" -eq 0 ]
then
  rebuild_system_config --update && 
  sleep 5 &&
  rebuild_user_config --update
else
  case "$1" in
    -h | --help | --usage) usage ;;
    -s | --system) rebuild_system_config --update ;;
    -u | --user) rebuild_user_config --update ;;
    -r | --rebuild) rebuild_system_config && rebuild_user_config ;;
    --rebuild-system) rebuild_system_config ;;
    --rebuild-user) rebuild_user_config ;;
    *) error $@ ;;
  esac
fi

# Finished updating
echo -e "\nDone!\n"
