{ pkgs, ... }:

{
  # Japanese input using fcitx
  i18n.inputMethod = {
    enabled = "fcitx";
    fcitx.engines = with pkgs.fcitx-engines; [mozc];
  };

  # Manage fcitx configuration
  xdg.configFile.fcitx = {
    source = ./config;
    target = "fcitx/config";
  };

  # Install fcitx configuration tool
  home.packages = [
    pkgs.fcitx-configtool
  ];

  # Tell programs to use fcitx as input method
  home.sessionVariables = {
    GTK_IM_MODULE = "fcitx";
    QT_IM_MODULE = "fcitx";
    XMODIFIERS = "fcitx";
  };
}
