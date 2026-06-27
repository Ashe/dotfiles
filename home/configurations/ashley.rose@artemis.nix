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
      JAVA_HOME = pkgs.jdk21;
    };

    sessionPath = [
      "$HOME/.cargo/bin"
    ];

    packages = with pkgs; [
      awscli2
      bat
      gnupg
      rust-analyzer
      tree
      git-credential-manager

      (pkgs.quarto.overrideAttrs (oldAttrs: {
        postPatch = (oldAttrs.postPatch or "") + ''
          substituteInPlace bin/quarto.js \
            --replace-fail "syntax-highlighting" "highlight-style"
        '';
      }))
    ];
  };

  # Configure git to use git-credential-manager
  programs.git.settings.credential.helper = "manager";

  # Fuzzy file finding
  programs.fzf.enable = true;
}
