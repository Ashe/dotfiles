{
  # Read and parse a JSON file while stripping out // comments
  fromJsonFile =
    filepath:
    let
      # Read the file content
      fileContent = builtins.readFile filepath;

      # Split into lines
      lines = builtins.split "\n" fileContent;

      # Filter out comment lines starting with //
      filterComments =
        line:
        if builtins.isString line then
          let
            trimmed = builtins.replaceStrings [ " " "\t" ] [ "" "" ] line;
          in
          !(builtins.match "//.*" trimmed != null)
        else
          true;

      # Reconstruct the file without comment lines
      filteredLines = builtins.filter filterComments lines;
      cleanContent = builtins.concatStringsSep "\n" (builtins.filter builtins.isString filteredLines);
    in
    builtins.fromJSON cleanContent;

  # Script that runs its arguments once a system tray is up, giving up waiting after 30 seconds
  waitForTray =
    pkgs:
    pkgs.writeShellScript "wait-for-tray" ''
      ${pkgs.lib.getExe' pkgs.glib "gdbus"} wait --session --timeout 30 org.kde.StatusNotifierWatcher
      exec "$@"
    '';
}
