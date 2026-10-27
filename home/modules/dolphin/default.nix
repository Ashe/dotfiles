{
  config,
  lib,
  pkgs,
  ...
}:

{
  options.dolphin.enable = lib.mkEnableOption "dolphin";

  config = lib.mkIf config.dolphin.enable {

    # Install the KDE file manager
    home.packages = with pkgs; [
      kdePackages.dolphin
    ];

    # KDE apps build 'Open With' from the XDG application menu, which only Plasma ships
    xdg.configFile."menus/applications.menu".text = ''
      <!DOCTYPE Menu PUBLIC "-//freedesktop//DTD Menu 1.0//EN"
        "http://www.freedesktop.org/standards/menu-spec/1.0/menu.dtd">
      <Menu>
        <Name>Applications</Name>
        <DefaultAppDirs/>
        <DefaultDirectoryDirs/>
        <Include>
          <All/>
        </Include>
      </Menu>
    '';

    # Open folders in Dolphin without taking over mimeapps.list, which other apps write to
    home.activation.dolphinDefaultFolderHandler = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run ${pkgs.xdg-utils}/bin/xdg-mime default org.kde.dolphin.desktop inode/directory
    '';
  };
}
