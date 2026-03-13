{ config, lib, ... }:

{
  options.btop.enable = lib.mkEnableOption "btop";

  config = lib.mkIf config.btop.enable {

    programs.btop = {
      enable = true;

      # Configuration for btop
      settings = {

        # Use default terminal background
        theme_background = false;

        # Use vim keys
        vim_keys = true;

        # Organise processes as a tree by default
        proc_tree = true;
      };
    };
  };
}
