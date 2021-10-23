{ pkgs, ... }:

with import <nixpkgs> {};
with builtins;
with lib;

{
  # Configure FISH
  programs.fish = {
    enable = true;

    promptInit = ''
      any-nix-shell fish --info-right | source
    '';

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
      if [ $XDG_SESSION_TYPE != tty ]
        if  status is-interactive &&
            command -sq tmux &> /dev/null &&
            not string match -q 'screen*' -- $TERM &&
            not string match -q 'tmux*' -- $TERM

          # Check if there's an unattached session
          mkdir -p $HOME/.cache/tmux
          tmux list-sessions > $HOME/.cache/tmux/sessions
          set sessions (cat $HOME/.cache/tmux/sessions | grep -v attached | cut -d: -f1)

          # Reattach to any unattached sessions available
          if set -q sessions[1]
            exec tmux attach-session -t "$sessions[1]"

          # Otherwise start a new session
          else
            exec tmux new-session
          end
        end
      end
    '';
  };
}
