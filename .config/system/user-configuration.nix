{ pkgs, ... }:

with import <nixpkgs> {};
with builtins;
with lib;

{
  # Packages to install
  home.packages = with pkgs; [

    # Programs
    brave
    discord
    dropbox
    dunst
    mpd
    mpv
    ncmpcpp
    neofetch
    neovim
    polybarFull
    rofi
    scrot
    slock
    youtube-dl

    # Personal fork of ST
    (st.overrideAttrs (oa: rec {
      src = builtins.fetchTarball {
        url = "https://github.com/Ashe/st/archive/master.tar.gz";
      };
      buildInputs = oa.buildInputs ++ [ harfbuzz ];
    }))

    # Fonts
    fira-code
    fira-code-symbols
    (pkgs.callPackage ./packages/waffle.nix {})
  ];

  # Allow proprietary software
  nixpkgs.config.allowUnfree = true;

  # Enable discovery of fonts from installed packages
  fonts.fontconfig.enable = lib.mkForce true;

  # Configure FISH
  programs.fish = {
    enable = true;

    # Install plugins
    plugins = [
      
      # 'Pure' prompt theme
      {
        name = "pure";
        src = pkgs.fetchFromGitHub {
          owner = "pure-fish";
          repo = "pure";
          rev = "9d17b2780165572bc6c181cd0e7c5d6dd13be5c1";
          sha256 = "16f8jq2697l0hfv848bn7vzxnbzql4qbi9brkniilfxb1dnllhzb";
        };
      }

      # Notifications when commands are completed
      {
        name = "done";
        src = pkgs.fetchFromGitHub {
          owner = "done";
          repo = "franciscolourenco";
          rev = "8fd2bc5c95a93b65452281459a167f1bbfb58990";
          sha256 = "16f8jq2697l0hfv848bn7vzxnbzql4qbi9brkniilfxb1dnllhzb";
        };
      }

    ];

    # Add functions
    functions = {
      sudo = {
        body = ''
          if test "$argv" = !!
            eval command sudo $history[1]
          else
            command sudo $argv
          end
        '';
        description = ''
          Replacement for Bash 'sudo !!' command to run last command using sudo
        '';
      };
    };

    # When shell is opened
    interactiveShellInit = ''

      # Allow vi keybindings
      fish_vi_key_bindings

      # Start tmux every session
      if  status is-interactive &&
          command -sq tmux &> /dev/null &&
          not string match -q 'screen*' -- $TERM &&
          not string match -q 'tmux*' -- $TERM &&
          test -z "$TMUX"

        # Check if there's an unattached session
        mkdir -p $HOME/.cache/tmux
        tmux list-sessions > $HOME/.cache/tmux/sessions
        set sessions (cat $HOME/.cache/tmux/sessions | grep -v attached | cut -d: -f1)

        # Reattach to any unattached sessions available
        if set -q tmux_unattached[1]
          exec tmux attach-session -t "$tmux_unattached[1]"

        # Otherwise start a new session
        else
          exec tmux new-session
        end
      end
    '';
  };

  # Enable fuzzy-file-finder
  programs.fzf.enable = true;

  # Configure git
  programs.git = {
    enable = true;
    userName  = "ashe";
    userEmail = "git@aas.sh";
  };

  # Enable dropbox service
  systemd.user.services.dropbox = {
    Unit = {
      Description = "Dropbox";
      After = [ "graphical-session-pre.target" ];
      PartOf = [ "graphical-session.target" ];
    };
    Service = {
      Restart = "on-failure";
      RestartSec = 1;
      ExecStart = "${pkgs.dropbox}/bin/dropbox";
      Environment = "QT_PLUGIN_PATH=/run/current-system/sw/${pkgs.qt5.qtbase.qtPluginPrefix}";
    };
    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
