{
  inputs,
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [ inputs.noctalia.homeModules.default ];

  options.noctalia.enable = lib.mkEnableOption "noctalia";
  options.noctalia.themeing.enable =
    lib.mkEnableOption "Noctalia theming for GTK, Qt, Umbriel, fonts and icons"
    // {
      default = true;
    };

  config = lib.mkIf config.noctalia.enable (
    lib.mkMerge [
      {

        # Configure ~/.config/noctalia/config.toml
        # Anything changed in the settings window is saved separately and takes precedence
        programs.noctalia = {
          enable = true;

          settings = {
            shell = {

              # Show admin password prompts, e.g. for syncing the greeter, as Umbriel has no agent of its own
              polkit_agent = true;

              # Typing in Umbriel's overview searches the launcher
              umbriel_overview_type_to_launch_enabled = true;
            };

            # Official Umbriel integration: layout and submap widget, layout picker panel
            plugins.enabled = [ "noctalia/umbriel-companion" ];
          };
        };
      }
      (lib.mkIf config.noctalia.themeing.enable {

        programs.noctalia.settings = {

          # Write the palette into other apps' themes whenever it changes
          theme.templates = {
            enable_builtin_templates = true;
            builtin_ids = [

              # KDE/Qt apps such as Dolphin, via ~/.config/kdeglobals
              "kcolorscheme"

              # GTK apps, via ~/.config/gtk-*/gtk.css and the adw-gtk3 theme
              "gtk3"
              "gtk4"

              # Umbriel borders, tab bars and overview, via ~/.config/umbriel/noctalia.toml
              "umbriel"
            ];

            # Copies Papirus into ~/.local/share/icons and recolors its folders to match the accent
            enable_community_templates = true;
            community_ids = [ "papirus-icons" ];
          };
        };

        # Use a modern UI font, which the shell and apps pick up through the 'sans-serif' default
        home.packages = with pkgs; [
          inter
          papirus-icon-theme

          # The GTK templates restyle adw-gtk3, and switch between its light and dark variants with dconf
          adw-gtk3
          dconf
        ];

        # Match GTK's font and icons to the Qt side; the GTK theme itself is left for Noctalia to switch
        dconf.settings."org/gnome/desktop/interface" = {
          font-name = "Inter 11";
          icon-theme = "Papirus-Dark";
        };
        fonts.fontconfig = {
          enable = true;
          defaultFonts.sansSerif = [ "Inter" ];
        };

        # Point KDE/Qt apps at the recolored Papirus, without taking over kdeglobals which Noctalia writes to
        home.activation.kdeIconTheme = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          run ${pkgs.kdePackages.kconfig}/bin/kwriteconfig6 --file kdeglobals --group Icons --key Theme Papirus-Dark
        '';

        # Qt only reads kdeglobals colors through KDE's platform theme
        qt = {
          enable = true;
          platformTheme = {
            name = "kde";
            package = pkgs.kdePackages.plasma-integration;
          };

          # Installed without overriding the style, so the platform theme picks Breeze from kdeglobals
          style.package = pkgs.kdePackages.breeze;
        };
      })
    ]
  );
}
