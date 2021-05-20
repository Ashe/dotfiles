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

  # Select internationalisation properties
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # Enable AMD gpu
  hardware = {
    opengl = {
      enable = true;
      driSupport = true;
      driSupport32Bit = true;
      extraPackages = with pkgs; [
        amdvlk
        rocm-opencl-icd
        rocm-opencl-runtime
      ];
      extraPackages32 = with pkgs; [
        driversi686Linux.amdvlk
      ];
    };
  };

  # Enable sound
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # User configurations
  users.users.ashe = {
    description = "Ashley Smith";
    isNormalUser = true;
    home = "/home/ashe";
    shell = pkgs.fish;
    extraGroups = [ "wheel" "networkmanager" ];
  };
  
  # List of directories to symlink in /run/current-system/sw
  environment.pathsToLink = [ "/libexec" ];

  # List packages installed in system profile
  environment.systemPackages = with pkgs; [

    # Allow per-user customisation
    home-manager

    # Nix utilities
    nix-index

    # Basic packages
    alacritty
    git
    gnome3.gnome-system-monitor
    gnome3.nautilus
    neofetch
    numlockx
    pavucontrol
    ranger
    ungoogled-chromium

    # System tools
    dex
    dosfstools
    gparted
    hardinfo
    htop
    killall
    networkmanager
    tree
    unzip
    xdg-user-dirs
    xwayland

    # Miscellaneous
    gnome3.adwaita-icon-theme
    (inxi.override { withRecommends = true; })
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
    BROWSER = "chromium";
    FILE = "ranger";
    FILEGUI = "nautilus";
  };
  
  # Allow proprietary software
  nixpkgs.config.allowUnfree = true;

  # Configure system-wide programs
  programs = {

    # Enable dconf
    dconf.enable = true;

    # Enable Steam
    steam.enable = true;

    # Enable FISH
    fish.enable = true;
  };

  # Configure system-wide services
  services = {

    # Enable CUPS to print documents
    printing.enable = true;

    # Enable the OpenSSH daemon
    openssh.enable = true;
  };

  # Open ports in the firewall.
  networking.firewall = {
    allowedTCPPorts = [ 17500 ];
    allowedUDPPorts = [ 17500 ];
    allowedUDPPortRanges = [
      { from = 32768; to = 60999; }
    ];
  };

  # Get location from geoclue
  location.provider = "geoclue2";

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "20.09"; # Did you read the comment?
}
