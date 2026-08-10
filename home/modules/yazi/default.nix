{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.yazi.enable = lib.mkEnableOption "yazi";

  config = lib.mkIf config.yazi.enable {

    # Configure yazi terminal file manager
    programs.yazi = {
      enable = true;
      keymap = fromTOML (builtins.readFile ./keymap.toml);
      extraPackages = with pkgs; [
        fzf
        zoxide
        ripgrep
      ];
    };
  };
}
