#!/bin/sh

# Fail on errors
set -e

# Gets the command name without path
cmd(){ echo `basename $0`; }

# Help command output
usage(){
  echo "`cmd` [ OPTION... ]"
  echo "Will UPDATE both system and user configurations by default."
  echo "-h, --help;       Show this prompt"
  echo "-s, --system;     Rebuild system configuration"
  echo "-u, --user;       Rebuild user configuration"
  echo "-r, --rebuild;    Rebuild both system and user configurations"
  echo "--update;         Update and rebuild both system and user configurations"
  exit 0;
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
    nix flake update './system'
  fi

  # Rebuild system configuration
  echo -e "\nRebuilding system configuration.."
  nixos-rebuild switch --flake './system#nixos' --use-remote-sudo
}

# Rebuild user configuration
rebuild_user_config()
{
  # Update user flake.lock
  if [ "$1" == "--update" ]
  then
    echo -e "\nUpdating user flake.lock.."
    nix flake update './users'
  fi

  # Rebuild user configuration
  echo -e "\nRebuilding user configuration.."
  nix build ./users#homeConfigurations.nixos.activationPackage 
  if [[ -f result/activate ]]; then
    ./result/activate && rm -rd result
  fi
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
    -s | --system) rebuild_system_config ;;
    -u | --user) rebuild_user_config ;;
    -r | --rebuild) rebuild_system_config && rebuild_user_config ;;
    --update) rebuild_system_config --update && rebuild_user_config --update ;;
    *) error $@ ;;
  esac
fi

# Finished updating
echo -e "\nDone!\n"
