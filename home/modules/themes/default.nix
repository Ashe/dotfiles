_: { config, lib, pkgs, xdg, ... }: let

  # List of all themes
  theme-list = [
    "Rose-Pine"
    "Tokyo-Night"
  ];

  # Convenience function for installing themes
  add-themes = (dir: (extension:
    lib.mkMerge (lib.lists.forEach theme-list (theme: {
      xdg.configFile."theme-${dir}-${theme}" = {
        source = ./${dir}/${theme}${extension};
        target = "themes/config/${dir}/${theme}${extension}";
      };
    })
  )));

  # Convenience function for installing wallpapers
  add-wallpapers = lib.mkMerge (lib.lists.forEach theme-list (theme: {
    xdg.configFile."theme-${theme}-wallpapers" = {
      source = ./wallpapers/${theme};
      target = "themes/wallpapers/${theme}";
    };
  }));

in {
  # Add options for theme configuration
  options.themes.enable = lib.mkEnableOption "themes";

  # Enable theme switching if desired
  config = lib.mkIf config.themes.enable (lib.mkMerge [

    # General configuration
    {
      # Install theming-specific packages
      home.packages = with pkgs; [

        # Allows access to 'gsettings'
        glib

        # Wallpaper daemon for wayland
        swww
      ];

      # Copy scripts
      xdg.configFile.theme-scripts = {
        source = ./scripts;
        target = "themes/scripts";
      };
    }

    # Copy wallpapers for themes
    add-wallpapers

    # Enable themes for kitty terminal
    (lib.mkIf config.kitty.enable (lib.mkMerge [(add-themes "kitty" ".conf") {
      programs.kitty.settings = {
        "include" = "~/.config/themes/kitty.conf";
      };
    }]))

  ]);
}
