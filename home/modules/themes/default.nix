_: { config, lib, pkgs, ... }:

{
  # Use theme name to import corresponding theme
  # @TODO: Make this module more functional
  _module.args = {
    theme = import ./rose-pine.nix pkgs;
  };
}
