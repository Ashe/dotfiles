{
  description = "Home manager flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    nur.url = "github:nix-community/NUR";
  };
  outputs = { self, nur, ... }@inputs: let overlays = [ nur.overlay ]; in {
    homeConfigurations = {
      nixos = inputs.home-manager.lib.homeManagerConfiguration {
        username = "ashe";
        homeDirectory = "/home/ashe";
        system = "x86_64-linux";
        configuration = { config, lib, pkgs, ...}@configInput: {

          # Import other config files
          imports = [
            ./config/fish/fish.nix
            ./config/mako/mako.nix
            ./config/mangohud/mangohud.nix
            ./config/mpd/mpd.nix
            ./config/ncmpcpp/ncmpcpp.nix
            ./config/neovim/neovim.nix
            ./config/sway/sway.nix
            ./config/tmux/tmux.nix
            ./config/waybar/waybar.nix
            ./config/xdg/xdg.nix
          ];

          # Packages to install
          home.packages = with pkgs; [

            # Import package entries from other files
            (callPackage ./packages/st/st.nix {})

            # Languages
            chicken
            guile
            nodejs
            python3Minimal

            # Libraries and frameworks
            hugo

            # Programs
            audacity
            blender
            godot
            gthumb
            lmms
            mpd
            mpv
            neofetch
            obsidian
            scanmem
            slack
            sublime4

            # Utilities
            any-nix-shell
            grim
            mpc_cli
            rnix-lsp
            slurp
            sway-contrib.grimshot
            wdisplays
            wl-clipboard
            wlogout
            wofi
            youtube-dl

            # Fonts
            dina-font
            fira-code
            fira-code-symbols
            font-awesome
            noto-fonts
            noto-fonts-cjk
            twitter-color-emoji
            ubuntu_font_family
          ];

          # Configure nixpkgs
          nixpkgs = {

            # Allow proprietary software
            config.allowUnfree = true;
          };

          # Enable discovery of fonts from installed packages
          fonts.fontconfig.enable = lib.mkForce true;

          # Configure GTK
          gtk = {

            # Enable GTK customisation
            enable = true;

            # Set theme
            theme = {
              name = "Nordic";
              package = pkgs.nordic;
            };

            # Set icon theme
            iconTheme = {
              name = "Papirus";
              package = pkgs.papirus-icon-theme;
            };

            # Set font
            font = {
              name = "Ubuntu";
              size = 12;
            };
          };

          # Configure programs
          programs = {

            # Enable fuzzy-file-finder
            fzf.enable = true;

            # Configure git
            git = {
              enable = true;
              userName  = "ashe";
              userEmail = "git@aas.sh";
            };

            # Enable lazygit client
            lazygit.enable = true;

            # Enable nix-index file database for nixpkgs
            nix-index.enable = true;
          };

          # Configure services
          services = {

            # Enable dropbox
            dropbox = {
              enable = true;
            };

            # Enable gammastep
            gammastep = {
              enable = true;
              provider = "manual";
              tray = true;
              latitude = 51.509;
              longitude = -0.126;
            };
          };
        };
      };
    };
  };
}
