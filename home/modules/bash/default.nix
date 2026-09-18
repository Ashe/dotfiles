{
  config,
  inputs,
  lib,
  pkgs,
  ...
}:

{
  options.bash = {
    enable = lib.mkEnableOption "bash";

    flylinePackage = lib.mkOption {
      type = lib.types.package;
      default = inputs.flyline.packages.${pkgs.stdenv.hostPlatform.system}.default;
      defaultText = lib.literalExpression "inputs.flyline.packages.\${pkgs.stdenv.hostPlatform.system}.default";
      description = "Flyline plugin for bash";
    };

    flylineAgentCommand = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = if lib.attrByPath [ "opencode" "enable" ] false config then "opencode2 run" else null;
      defaultText = lib.literalExpression ''
        if config.opencode.enable then "opencode2 run" else null
      '';
      description = "Command Flyline uses for agent mode, or null to leave agent mode unconfigured";
    };
  };

  config = lib.mkIf config.bash.enable {
    home.packages = [ config.bash.flylinePackage ];

    # Configure bash shell
    programs.bash = {

      ###########
      # General #
      ###########

      # Enable bash
      enable = true;

      # Enable bash features
      enableCompletion = true;
      enableVteIntegration = true;
      shellOptions = [
        "histappend"
        "checkjobs"

        # Pattern matching used by flyline's completion support
        "extglob"
        "nocaseglob"
        "globstar"
        "dotglob"
      ];

      # History management
      historySize = 10000;
      historyFileSize = 10000;
      historyFile = "$HOME/.bash_history";
      historyIgnore = [
        "rm *"
        "pkill *"
        "cp *"
        "open"
        "open *"
        "edit"
        "edit *"
      ];

      # Configure shell aliases for bash
      shellAliases = {

        # Run things with XWayland easily
        run-with-xwayland = "env -u WAYLAND_DISPLAY";
      };

      # Additional interactive configuration
      initExtra =
        let
          libraryName = "libflyline${pkgs.stdenv.hostPlatform.extensions.sharedLibrary}";
        in
        ''
          ############################
          # Additional configuration #
          ############################

          # Replace readline with flyline
          enable -f "${config.bash.flylinePackage}/lib/${libraryName}" flyline

          # Compact transient prompt: dim time, user/host and folder followed by a bold lambda
          export PS1_FINAL='\e[2;90m\t \u@\h \W\e[0m \e[1;35mλ\e[0m '

          # Store rich, synchronized history locally
          flyline history --backend flyline

          # Keep flycomp completion synthesis explicitly enabled
          flyline suggestions flycomp --enabled true

          # Distinguish popup box/inline suggestions from text and background
          flyline set-style secondary-text="dim blue" inline-suggestion="dim blue"

          # Use a steady, terminal-coloured block cursor
          flyline set-cursor --backend flyline --style reverse --effect none --interpolate none

          # Emacs-style navigation and inline suggestion acceptance
          flyline key remap Ctrl+p Up
          flyline key remap Ctrl+n Down
          flyline key bind Ctrl+l inlineSuggestionAvailable=inlineSuggestionAccept
          flyline key bind Ctrl+l tabCompletionEntrySelected=tabCompletionAcceptEntry

          ${lib.optionalString (config.programs.fzf.enable && config.programs.fzf.enableBashIntegration) ''
            # Flyline replaces readline, so restore fzf's file widget explicitly
            flyline key bind Ctrl+t 'always=runBashCommand(fzf-file-widget)'
          ''}

          ${lib.optionalString (lib.hasAttr "jujutsu" pkgs) ''
            # Dynamic Jujutsu completions include revisions, bookmarks and aliases
            if command -v jj >/dev/null 2>&1; then
              source <(COMPLETE=bash jj)

              # Allow completion within revsets such as main..feature and foo::bar
              COMP_WORDBREAKS="''${COMP_WORDBREAKS//:}"
            fi
          ''}

          ${lib.optionalString (config.bash.flylineAgentCommand != null) ''
            # Turn natural-language requests prefixed with ": " into commands
            flyline set-agent-mode \
              --trigger-prefix ": " \
              --system-prompt "Be concise. Answer with a JSON array of at most 3 items with objects containing: command and description. Command will be a Bash command. " \
              --command ${lib.escapeShellArg config.bash.flylineAgentCommand}
          ''}
        '';

      # Additional configuration for .bash_profile
      profileExtra = ''
        ############################
        # Additional configuration #
        ############################

        # Activate homebrew if installed
        if [[ -x /opt/homebrew/bin/brew ]]; then
          eval "$(/opt/homebrew/bin/brew shellenv bash)"
        fi
      '';
    };
  };
}
