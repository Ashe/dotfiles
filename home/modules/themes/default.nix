_: { config, lib, pkgs, xdg, ... }: let

  # List of all themes
  theme-list = [
    {
      name = "Rose-Pine";
      vs-code-theme = "Rosé Pine";
    }
    {
      name = "Tokyo-Night";
      vs-code-theme = "Tokyo Night";
    }
  ];

  # Convenience function for installing themes
  add-themes = (dir: (extension:
    lib.mkMerge (lib.lists.forEach theme-list (theme: {
      xdg.configFile."themes/config/${dir}/${theme.name}${extension}" = {
        source = ./${dir}/${theme.name}${extension};
      };
    })
  )));

  # Convenience function for installing wallpapers
  add-wallpapers = lib.mkMerge (lib.lists.forEach theme-list (theme: {
    xdg.configFile."themes/wallpapers/${theme.name}"= {
      source = ./wallpapers/${theme.name};
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
      xdg.configFile."themes/scripts".source = ./scripts;

      # Create theme data file
      xdg.configFile."themes/theme-data.conf" = {
        text = (lib.strings.concatLines (
          [ "<theme-name>|<vs-code-theme>" ] ++
          (lib.lists.forEach theme-list (theme:
             theme.name
             + "|" + theme.vs-code-theme
          ))
        ));
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

    # Enable themes for vs-code
    (lib.mkIf config.vs-code.enable {
      xdg.configFile."Code/User/settings.json" = {
        target = "Code/User/base_settings.json";
      };
    })

  ]);
}
