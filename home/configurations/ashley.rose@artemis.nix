{ pkgs, ... }:

{
  ##################
  # Custom modules #
  ##################

  btop.enable = true;
  fastfetch.enable = true;
  neovim.enable = true;
  starship.enable = true;
  zed.enable = true;
  wezterm.enable = true;
  zsh.enable = true;

  ##################
  # Configurations #
  ##################

  home = {

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    packages = with pkgs; [
      bat
      gnupg
    ];

    # Do not change this
    stateVersion = "25.05";
  };
}
