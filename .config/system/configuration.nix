# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  # Import other config files
  imports = [

    # Include the results of the hardware scan
    /etc/nixos/hardware-configuration.nix
  ];

  # Enable grub as bootloader
  boot.loader = {
    systemd-boot.enable = false;
    efi.canTouchEfiVariables = true;
    efi.efiSysMountPoint = "/boot/EFI";
    grub = {
      enable = true;
      efiSupport = true;
      version = 2;
      devices = [ "nodev" ];
    };
  };

  # Define hostname
  networking.hostName = "nixos";
  # networking.wireless.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/London";

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp4s0.useDHCP = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Configure keymap in X11
  services.xserver.layout = "us";
  services.xserver.xkbOptions = "eurosign:e";

  # Enable CUPS to print documents
  services.printing.enable = true;

  # Enable sound
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # User configurations
  users.users.ashe = {
    description = "Ashley Smith";
    isNormalUser = true;
    home = "/home/ashe";
    extraGroups = [ "wheel" "networkmanager" ];
  };
  
  # List of directories to symlink in /run/current-system/sw
  environment.pathsToLink = [ "/libexec" ];

  # List packages installed in system profile
  environment.systemPackages = with pkgs; [

    # Allow per-user customisation
    home-manager

    # Basic packages
    alacritty
    dex
    git
    gnome3.gnome-system-monitor
    gnome3.nautilus
    neofetch
    numlockx
    pavucontrol
    ranger
    tmux

    # System tools
    dosfstools
    gparted
    hardinfo
    htop
    killall
    networkmanager
    xdg-user-dirs
    
    # Miscellaneous
    jq
    libnotify
    mtools
    pciutils
    pulseaudio-ctl
  ];

  # Variables for changing what programs are used
  environment.variables = {
    TERMINAL = "st";
    EDITOR = "nvim";
    BROWSER = "brave";
    FILE = "ranger";
    FILEGUI = "nautilus";
  };
  
  # Allow proprietary software
  nixpkgs.config.allowUnfree = true;

  # Enable Steam
  programs.steam.enable = true;

  # Enable FISH
  programs.fish.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  networking.firewall = {
    allowedTCPPorts = [ 17500 ];
    allowedUDPPorts = [ 17500 ];
  };

  # Get location from geoclue
  location.provider = "geoclue2";

  # Enable redshift
  services.redshift = {
    enable = true;
    brightness = {
      day = "1";
      night = "1";
    };
    temperature = {
      day = 5500;
      night = 3700;
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?
}
