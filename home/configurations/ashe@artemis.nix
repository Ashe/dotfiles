{ config, lib, pkgs, ... }:

{
  ##################
  # Custom modules #
  ##################

  btop.enable = true;
  neovim.enable = true;
  starship.enable = true;
  zsh.enable = true;

  ##################
  # Configurations #
  ##################

  # Configure user experience
  home = {

    # Home variables
    stateVersion = "22.11";

    # Set environment variables
    sessionVariables = {
      FILE = "ranger";
    };

    # Packages to install
    packages = with pkgs; [

      # Programs
      ranger

      # Utilities
      clang-tools
    ];
  };

  # Configure programs
  programs = {

    # Enable lazygit client
    lazygit.enable = true;

    # Enable nix-index file database for nixpkgs
    nix-index.enable = true;

    # Fuzzy file finding
    fzf.enable = true;

    # Cheat sheets
    navi.enable = true;
  };
}
