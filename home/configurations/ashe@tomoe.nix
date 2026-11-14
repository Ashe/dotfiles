{ inputs, pkgs, ... }:

{
  ##################
  # Custom modules #
  ##################

  bash.enable = true;
  btop.enable = true;
  claude.enable = true;
  dolphin.enable = true;
  fastfetch.enable = true;
  flameshot.enable = true;
  mangohud.enable = true;
  neovim.enable = true;
  noctalia.enable = true;
  obs-studio.enable = true;
  obsidian.enable = true;
  opencode.enable = true;
  starship.enable = true;
  t3code.enable = true;
  umbriel.enable = true;
  wezterm.enable = true;
  yazi.enable = true;
  zed.enable = true;
  zen-browser.enable = true;

  ##################
  # Configurations #
  ##################

  # Configure user experience
  home = {

    # Packages to install
    packages = with pkgs; [

      # Packages from inputs
      inputs.hytale-launcher.packages.${pkgs.stdenv.hostPlatform.system}.default

      # Programs
      bat
      chatterino2
      discord
      glow
      gnome-sound-recorder
      halloy
      magic-wormhole-rs
      mission-center
      scanmem
      sshfs
      streamlink
      tray-tui
      tree
      vlc

      # Utilities
      xclip
    ];

    # Environment variables
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  multiverse = {
    enable = true;
    config.permittedInsecurePackages = [ "electron-25.9.0" ];
    # Streamlink has been removed from nixpkgs so install the last version
    pins.streamlink-twitch-gui-bin = "2.5.3";
  };

  # Configure nixpkgs
  nixpkgs.config = {

    # Allow proprietary software
    allowUnfreePredicate = _: true;
  };

  # Configure programs
  programs = {

    # Configure git
    git = {
      settings.user = {
        name = "ashe";
        email = "git@aas.sh";
      };
      lfs.enable = true;
    };

    # Configure jj vcs
    jujutsu.settings.user = {
      name = "ashe";
      email = "git@aas.sh";
    };

    # Terminal UI client for jj
    jjui.enable = true;

    # Fuzzy file finding
    fzf.enable = true;

    # Alternative to find
    fd.enable = true;
  };

  # Workspaces by position, with the programs that open on them at login
  umbriel.workspaces = [
    {
      layout = "scrolling";
      programs = [
        {
          command = "zen-beta";
          maximize = true;
        }
      ];
    }
    {
      layout = "scrolling";
      programs = [
        {
          command = "discord";
          maximize = true;
        }
      ];
    }
    {
      layout = "scrolling";
      programs = [
        {
          command = "steam";
          maximize = true;
        }
      ];
    }
    { layout = "master"; }
  ];

  # Started at login without a workspace
  umbriel.autostart = [ "streamlink-twitch-gui --tray" ];

  programs.umbriel.settings.output."AOC 24G4 12VQ2HA007104" = {
    mode = "1920x1080@180";

    # Keep all of umbriel.workspaces around from login, so startup programs have somewhere to land
    min_workspaces = 4;

    # FreeSync while a fullscreen window is focused, so games don't stutter below 180fps
    vrr = "fullscreen";

    # Let fullscreen games that ask for it present immediately for lower input latency
    tearing = true;
  };

  # Enable blanket for soothing noises
  services.blanket.enable = true;

  # Enable discovery of fonts
  fonts.fontconfig.enable = true;
}
