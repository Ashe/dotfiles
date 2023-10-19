_: { config, lib, pkgs, ... }:

{
  # Add options for fcitx, a utility for changing keyboard language
  options.fcitx.enable = lib.mkEnableOption "fcitx";

  # Install fcitx if desired */
  config = lib.mkIf config.fcitx.enable {

    # Japanese input using fcitx */
    i18n.inputMethod = {
      enabled = "fcitx5";
      fcitx5.addons = with pkgs; [
        fcitx5-mozc
        fcitx5-gtk
      ];
    };

    # Manage fcitx configuration */
    xdg.configFile."fcitx/config".source = ./config;

    # Tell programs to use fcitx as input method */
    home.sessionVariables = {
      GTK_IM_MODULE = "fcitx";
      QT_IM_MODULE = "fcitx";
      XMODIFIERS ="@im=fcitx";
      SDL_IM_MODULE = "fcitx";
      GLFW_IM_MODULE = "ibus";
    };
  };
}
