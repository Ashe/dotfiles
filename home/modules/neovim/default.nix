{
  config,
  lib,
  pkgs,
  ...
}:

# Plugins to enable in neovim
let
  pluginDefs = import ./plugins.nix { inherit pkgs lib; };
in
{
  options = {

    # Option to enable neovim
    neovim.enable = lib.mkEnableOption "neovim";

    # Option to enable individual plugin configurations
    neovim.plugins = lib.mapAttrs (name: _: {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = "Enable the neovim plugin ${name}";
      };
    }) pluginDefs;
  };

  config = lib.mkIf config.neovim.enable (
    lib.mkMerge (
      [
        {
          # Install neovim
          programs.neovim = {
            enable = true;
            vimAlias = true;
            vimdiffAlias = true;
            withPython3 = true;
            withRuby = false;

            # General neovim configuration
            initLua = builtins.readFile ./config.lua;

            # Install plugin dependencies and expose to neovim
            extraPackages = lib.concatLists (
              lib.mapAttrsToList (
                name: def: if config.neovim.plugins.${name}.enable then def.extraPackages or [ ] else [ ]
              ) pluginDefs
            );
          };
        }
      ]
      ++ lib.mapAttrsToList (
        name: def:

        # Install and configure enabled plugins
        lib.mkIf config.neovim.plugins.${name}.enable {
          programs.neovim.plugins = map (p: { plugin = p; }) (def.extraPlugins or [ ]) ++ [
            {
              plugin = def.package;
              type = "lua";
              config =
                let

                  # Build a nice header comment per plugin
                  comment = ''

                    -------------------------------------
                    -- ${name}
                    -------------------------------------

                  '';

                  # Build the body from either:
                  #   A: Enabling `require`
                  #   B: Providing `extraConfig`
                  #   C: Nothing, defaults to reading a file at ./plugins/PLUGIN.lua
                  body =
                    if def ? extraConfig then
                      def.extraConfig
                    else if def ? require && def.require then
                      "require('${name}')"
                    else
                      builtins.readFile ./plugins/${name}.lua;

                  # Finalise plugin config content
                in
                comment + body;
            }
          ];
        }
      ) pluginDefs
    )
  );
}
