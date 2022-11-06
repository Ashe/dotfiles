_: { config, lib, pkgs, ... }:

{
  # Add options for zsh shell
  options.zsh.enable = lib.mkEnableOption "zsh";

  # Install and configure zsh if desired
  config = lib.mkIf config.zsh.enable {

    # Configure zsh shell
    programs.zsh = {

      # Enable zsh
      enable = true;

      # Enable zsh features
      enableCompletion = true;
      enableSyntaxHighlighting = true;
      enableVteIntegration = true;

      # Install plugins
      plugins = [

        # Vi keybindings
        {
          name = "zsh-vi-mode";
          file = "./share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
          src = pkgs.zsh-vi-mode;
        }

        # Autosuggestions
        {
          name = "zsh-autosuggestions";
          file = "./share/zsh-autosuggestions/zsh-autosuggestions.zsh";
          src = pkgs.zsh-autosuggestions;
        }
      ];
    };
  };
}
