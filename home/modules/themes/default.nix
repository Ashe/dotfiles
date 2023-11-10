_: { config, lib, pkgs, xdg, ... }: let

  # Data for all themes
  themes = {

    catppuccin-mocha = {
      name = "Catppuccin-Mocha";
      gtk = { theme = "Catppuccin-Mocha"; package = pkgs.catppuccin-gtk; };
      icon = { theme = "Tela-circle-dracula"; package = pkgs.tela-circle-icon-theme; };
      vs-code-theme = "Catppuccin Mocha";
    };

    cyberpunk-edge = {
      name = "Cyberpunk-Edge";
      # TODO: Fix this when cyberpunk-edge available
      gtk = { theme = "Tokyonight-Dark-B"; package = pkgs.tokyo-night-gtk; };
      icon = { theme = "Tela-circle-yellow"; package = pkgs.tela-circle-icon-theme; };
      vs-code-theme = "cyberpunk2077";
    };

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
        source = ./config/${dir}/${theme.name}${extension};
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
      # Copy scripts and other data
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

        # Allows for json parsing
        jq

        # Allows for substitution of variables
        envsubst
      ];
    }

    # Install theme wallpapers
    (lib.mkMerge (lib.lists.forEach theme-list (theme: {
      xdg.configFile."themes/wallpapers/${theme.name}"= {
        source = ./wallpapers/${theme.name};
      };
    })))

    # Install gtk themes
    (lib.mkIf config.gtk.enable {
      xdg.configFile."gtk-3.0/settings.ini" = {
        target = "gtk-3.0/base_settings.ini";
      };
    })

    # Install qt themes
    (lib.mkIf config.qt.enable (lib.mkMerge [(add-themes "qt5ct" ".conf") {
      xdg.configFile."qt5ct/qt5ct.conf" = {
        target = "qt5ct/base_qt5ct.conf";
      };
    }]))

    # Install kvantum themes
    (lib.mkMerge (lib.lists.forEach theme-list (theme: {
      xdg.configFile."Kvantum/${theme.name}" = {
        source = ./config/kvantum/${theme.name};
      };
    })))

    # Enable css themes
    (add-themes "css" ".css")

    # Enable themes for waybar
    (lib.mkIf config.waybar.enable {
      xdg.configFile."waybar/extra-style.css".text = ''
        @import "theme.css";
      '';
    })

    # Enable themes for rofi application switcher
    (lib.mkIf config.rofi.enable (lib.mkMerge [(add-themes "rofi" ".rasi") {
      xdg.configFile."rofi/extra-config.rasi".text = ''
        @theme "~/.config/themes/rofi.rasi"
      '';
    }]))

    # Enable themes for dunst
    (lib.mkIf config.waybar.enable (lib.mkMerge [(add-themes "dunst" "") {
      xdg.configFile."dunst/dunstrc" = {
        target = "dunst/base_dunstrc";
      };
    }]))

    # Enable themes for wlogout
    (lib.mkIf config.wlogout.enable {
      xdg.configFile."wlogout/extra-style.css".text = ''
        @import "theme.css";
      '';
    })

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

    # Enable themes for hyprland
    (lib.mkIf config.hyprland.enable (lib.mkMerge [(add-themes "hyprland" ".conf") {
      wayland.windowManager.hyprland.extraConfig = ''

        # Reset theme
        exec = ~/.config/themes/scripts/switch-theme.sh -i

        # Change hyprland colourscheme
        source=~/.config/themes/hyprland.conf
      '';
    }]))

  ]);
}
