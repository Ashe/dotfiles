_: { config, lib, pkgs, ... }:

{
  # Add options for btop system monitor
  options.btop.enable = lib.mkEnableOption "btop";

  # Install btop if desired
  config = lib.mkIf config.btop.enable {

    # Configure btop
    programs.btop = {

      # Enable btop
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
