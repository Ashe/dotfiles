{ pkgs, ... }:

{
  ##################
  # Custom modules #
  ##################

  btop.enable = true;
  fastfetch.enable = true;
  neovim.enable = true;
  starship.enable = true;
  wezterm.enable = true;
  yazi.enable = true;
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
      awscli2
      bat
      gnupg
      tree
    ];
  };

  # Fuzzy file finding
  programs.fzf.enable = true;
}
