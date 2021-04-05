{ config, lib, pkgs, ... }:

{
  # Set your time zone.
  time.timeZone = "Europe/London";

  # List of directories to symlink in /run/current-system/sw
  environment.pathsToLink = [ "/libexec" ];

  # Enable and configure X server
  services.xserver = {
    enable = true;

    # Use lightdm as display manager
    displayManager = {
      lightdm.enable = true;
    };

    # Use i3-gaps as window manager
    windowManager.i3 = {
      enable = true; 
      package = pkgs.i3-gaps;
    };
  };

  # List packages installed in system profile
  environment.systemPackages = with pkgs; [
    brave
    discord
    dunst
    feh
    fish
    git
    gnome3.nautilus
    neofetch
    neovim
    polybar
    ranger
    rofi
    steam
    slock
    tmux

    # Personal fork of ST
    (st.overrideAttrs (oa: rec {
      src = builtins.fetchTarball {
        url = "https://github.com/Ashe/st/archive/master.tar.gz";
      };
      buildInputs = oa.buildInputs ++ [ harfbuzz ];
    }))
  ];

  # Variables for changing what programs are used
  environment.variables = {
    TERMINAL = "st";
    EDITOR = "nvim";
    BROWSER = "brave";
    FILE = "ranger";
    FILEGUI = "nautilus";
  };

  # Fonts used throughout system
  fonts.fonts = with pkgs; [
    fira-code
    fira-code-symbols
    noto-fonts
    noto-fonts-emoji
    (pkgs.callPackage ./packages/waffle.nix {})
  ];

  # Allow proprietary software
  nixpkgs.config.allowUnfree = true;

  # Enable steam
  programs.steam.enable = true;

  # Enable FISH
  programs.fish.enable = true;

  # User configurations
  users.users.ashe = {
    description = "Ashley Smith";
    isNormalUser = true;
    home = "/home/ashe";
    shell = pkgs.fish;
    extraGroups = [ "wheel" "networkmanager" ];
  };
}
