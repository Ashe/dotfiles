{ config, lib, pkgs, ... }:

with lib;

{
  # Configure beets music library manager
  programs.beets = {
    
    # Enable beets
    enable = true;

    # Configure settings
    settings = {
      directory = "~/Music";
      library = "~/.config/beets/library.db";
      import = {
        write = true;
        log = "beetslog.txt";
      };
      paths = {
        default = "$albumartist/$album%aunique{}/$title";
        singleton = "Non-Album/$artist/$title";
        comp = "Compilations/$album%aunique{}/$title";
      };
      art_filename = "album_art";
      plugins = [
        "fromfilename"
        "fetchart"
        "embedart"
        "info"
      ];
      replace = {
        "[\\\\/]" = "_";
        "^\\." = "_";
        "[\\x00-\\x1f]" = "_";
        "[<>:\"\\?\\*\\|]" = "_";
        "\\.$" = "_";
        "\\s+$" = "";
        "^\\s+" = "";
        "^-" = "_";
      };
    };
  };
}
