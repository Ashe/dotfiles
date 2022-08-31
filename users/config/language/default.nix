{ pkgs, ... }:

{
  # Japanese input using fcitx
  i18n.inputMethod = {
    enabled = "fcitx";
    fcitx.engines = with pkgs.fcitx-engines; [mozc];
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
