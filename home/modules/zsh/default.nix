{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.zsh.enable = lib.mkEnableOption "zsh";

  config = lib.mkIf config.zsh.enable {

    # Configure zsh shell
    programs.zsh = {

      ###########
      # General #
      ###########

      # Enable zsh
      enable = true;

      # Enable zsh features
      enableCompletion = true;
      enableVteIntegration = true;

      # History management
      history = {
        size = 10000;
        path = "$HOME/.zsh_history";
        ignorePatterns = [
          "rm *"
          "pkill *"
          "cp *"
        ];
      };

      # Configure shell aliases for zsh
      shellAliases = {

        # Run things with XWayland easily
        run-with-xwayland = "env -u WAYLAND_DISPLAY";
      };

      # Additional init configuration
      initContent = ''
        ############################
        # Additional configuration #
        ############################

        # Accept auto-suggestion
        zvm_after_init_commands+=('bindkey "^L" autosuggest-accept')

        # Substring history search
        zvm_after_init_commands+=('bindkey "^P" history-substring-search-up')
        zvm_after_init_commands+=('bindkey "^N" history-substring-search-down')

        ${lib.optionalString (lib.hasAttr "jujutsu" pkgs) ''
          # Jujutsu completions
          if command -v jj >/dev/null 2>&1; then source <(jj util completion zsh); fi
        ''}
      '';

      # Additional configuration for .zprofile
      profileExtra = ''
        ############################
        # Additional configuration #
        ############################

        # Activate homebrew if installed
        if [[ -x /opt/homebrew/bin/brew ]]; then
          eval "$(/opt/homebrew/bin/brew shellenv zsh)"
        fi
      '';

      ###########
      # Plugins #
      ###########

      syntaxHighlighting.enable = true;
      historySubstringSearch.enable = true;

      # Autosuggestions
      autosuggestion = {
        enable = true;
        strategy = [
          "history"
          "completion"
        ];
      };

      # Install extra plugins
      plugins = [

        # Vi keybindings
        {
          name = "zsh-vi-mode";
          file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
          src = pkgs.zsh-vi-mode;
        }

      ];
    };
  };
}
