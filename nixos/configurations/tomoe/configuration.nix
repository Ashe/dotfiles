{
  pkgs,
  ...
}:

{

  ##################
  # Custom modules #
  ##################

  cosmic.enable = true;
  dropbox.enable = true;
  steam.enable = true;

  ##################
  # Configurations #
  ##################

  # Bootloader
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Configure networking
  networking = {
    hostName = "tomoe";
    networkmanager = {
      enable = true;

      # Allow connection to homelab
      insertNameservers = [ "192.168.1.83" ];
    };
  };

  # Enable GPU
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users = {
    defaultUserShell = pkgs.zsh;
    users.ashe = {
      isNormalUser = true;
      extraGroups = [
        "networkmanager"
        "wheel"
      ];
    };
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Install system-wide packages
  environment.systemPackages = with pkgs; [
    jujutsu
  ];

  # Ensure zsh is available to users
  programs.zsh.enable = true;

  # Enable flatpak package manager
  services.flatpak.enable = true;

  # Set time zone
  time.timeZone = "Europe/London";

  # Configure internationalisation properties
  i18n = {
    defaultLocale = "en_GB.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_GB.UTF-8";
      LC_IDENTIFICATION = "en_GB.UTF-8";
      LC_MEASUREMENT = "en_GB.UTF-8";
      LC_MONETARY = "en_GB.UTF-8";
      LC_NAME = "en_GB.UTF-8";
      LC_NUMERIC = "en_GB.UTF-8";
      LC_PAPER = "en_GB.UTF-8";
      LC_TELEPHONE = "en_GB.UTF-8";
      LC_TIME = "en_GB.UTF-8";
    };
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  system.stateVersion = "26.05";
}
