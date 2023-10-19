_: { config, lib, pkgs, xdg, ... }: let

  # Data for all themes
  themes = {

    rose-pine = {
      name = "Rose-Pine";
      gtk = { theme = "rose-pine"; package = pkgs.rose-pine-gtk-theme; };
      icon = { theme = "Tela-circle-pink"; package = pkgs.tela-circle-icon-theme; };
      vs-code-theme = "Rosé Pine";
    };

    tokyo-night = {
      name = "Tokyo-Night";
      gtk = { theme = "Tokyonight-Dark-B"; package = pkgs.tokyo-night-gtk; };
      icon = { theme = "Tela-circle-purple"; package = pkgs.tela-circle-icon-theme; };
      vs-code-theme = "Tokyo Night";
    };
  };

  # Themes as a list
  theme-list = builtins.attrValues themes;

  # All theme packages
  theme-packages = (lib.lists.concatMap (theme: [
    theme.gtk.package
    theme.icon.package
  ]) theme-list);

  # Convenience function for installing themes
  add-themes = (dir: (extension:
    lib.mkMerge (lib.lists.forEach theme-list (theme: {
      xdg.configFile."themes/config/${dir}/${theme.name}${extension}" = {
        source = ./${dir}/${theme.name}${extension};
      };
    })
  )));

in {
  # Add options for theme configuration
  options.themes.enable = lib.mkEnableOption "themes";

  # Enable theme switching if desired
  config = lib.mkIf config.themes.enable (lib.mkMerge [

    # General configuration
    {
      # Copy scripts
      xdg.configFile."themes/scripts".source = ./scripts;

      # Create theme data file
      xdg.configFile."themes/theme-data.conf" = {
        text = (lib.strings.concatLines (
          [ "<theme-name>|<gtk>|icons>|<vs-code>" ] ++
          (lib.lists.forEach theme-list (theme:
             theme.name
             + "|" + theme.gtk.theme
             + "|" + theme.icon.theme
             + "|" + theme.vs-code-theme
          ))
        ));
      };

      # Install theming-specific packages
      home.packages = with pkgs; theme-packages ++  [

        # Wallpaper daemon for wayland
        swww

        # Allows access to 'kvantummanager' for configuring QT
        libsForQt5.qtstyleplugin-kvantum
      ];
    }

    # Install theme wallpapers
    (lib.mkMerge (lib.lists.forEach theme-list (theme: {
      xdg.configFile."themes/wallpapers/${theme.name}"= {
        source = ./wallpapers/${theme.name};
      };
    })))

    # Enable gtk themes
    (lib.mkIf config.gtk.enable {
      xdg.configFile."gtk-3.0/settings.ini" = {
        target = "gtk-3.0/base_settings.ini";
      };
    })

    # Enable themes for hyprland
    (lib.mkIf config.hyprland.enable (lib.mkMerge [(add-themes "hyprland" ".conf") {
      wayland.windowManager.hyprland.extraConfig = ''
        source=~/.config/themes/hyprland.conf
      '';
    }]))

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
