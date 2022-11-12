# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

_: { config, lib, pkgs, ... }:

{
  ##################
  # Custom modules #
  ##################

  steam.enable = true;
  nix.flakes.enable = true;

  ##################
  # Configurations #
  ##################

  # Specify kernel to use
  boot.kernelPackages = pkgs.linuxPackages_latest;

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

  # Configure hardware
  hardware = {

    # Enable bluetooth
    bluetooth.enable = true;
  };

  # Enable sound
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # User configurations
  users.users = {
    ashe = {
      description = "Ashley Smith";
      isNormalUser = true;
      extraGroups = [ "wheel" "networkmanager" ];
      shell = pkgs.zsh;
    };
  };

  # Configure environment related settings
  environment = {

    # List of directories to symlink in /run/current-system/sw
    pathsToLink = [ "/libexec" ];

    # List packages installed in system profile
    systemPackages = with pkgs; [

      # Basic packages
      alacritty
      git
      git-lfs
      gnome.gnome-system-monitor
      gnome.nautilus
      neofetch
      numlockx
      pavucontrol
      ranger

      # System tools
      dex
      dosfstools
      gparted
      hardinfo
      killall
      networkmanager
      tree
      unzip
      wget
      wlr-randr

      # Miscellaneous
      gnome.adwaita-icon-theme
      (inxi.override { withRecommends = true; })
      jq
      libnotify
      mtools
      pciutils
      pulseaudio-ctl
      xdg-utils
    ];
  };

  # Manage fonts
  fonts = {

    # Download font packages
    fonts = with pkgs; [
      (nerdfonts.override { fonts = [ "FiraCode" ]; })
      dina-font
      font-awesome
      noto-fonts
      source-han-sans
      source-han-serif
      source-han-mono
      source-han-code-jp
      twitter-color-emoji
      ubuntu_font_family
    ];

    # Enable default fonts
    enableDefaultFonts = true;

    # Configure default fonts
    fontconfig = {
      defaultFonts = {
        serif = [ "Ubuntu" "Regular" ];
        sansSerif = [ "Ubuntu" "Regular" ];
        monospace = [ "FiraCode Nerd Font" "Regular" ];
      };
    };
  };

  # Configure nixpkgs
  nixpkgs.config = {

    # Allow proprietary software
    allowUnfree = true;
  };

  # Configure system-wide programs
  programs = {

    # Enable dconf
    dconf.enable = true;
  };

  # Configure system-wide services
  services = {

    # Enable bluetooth support and device management (via bluetooth manager)
    blueman.enable = true;

    # Enable flatpak for non-nix packages (or temporary broken packages)
    flatpak.enable = true;

    # Enable gnome virtual file system (enables trash)
    gvfs.enable = true;

    # Enable the OpenSSH daemon
    openssh.enable = true;

    # Enable Pipewire for a/v (used for screensharing)
    pipewire.enable = true;

    # Enable CUPS to print documents
    printing.enable = true;
  };

  # Enable XDG desktop integration
  xdg.portal = {
    enable = true;
    extraPortals = [
      pkgs.xdg-desktop-portal
      pkgs.xdg-desktop-portal-wlr
      pkgs.xdg-desktop-portal-gtk
    ];
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
