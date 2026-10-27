{
  inputs,
  config,
  lib,
  ...
}:

{
  imports = [
    inputs.noctalia.nixosModules.default
    inputs.umbriel.nixosModules.default
    inputs.noctalia-greeter.nixosModules.default
  ];

  options.noctalia.enable = lib.mkEnableOption "noctalia";

  config = lib.mkIf config.noctalia.enable {

    # Pre-built binaries for the shell, greeter, compositor and portal
    nix.settings = {
      substituters = [
        "https://noctalia.cachix.org"
        "https://umbriel.cachix.org"
      ];
      trusted-public-keys = [
        "noctalia.cachix.org-1:pCOR47nnMEo5thcxNDtzWpOxNFQsBRglJzxWPp3dkU4="
        "umbriel.cachix.org-1:JfNq/2yg2S6D6z4Z2dVSZrZlDPQTKtexB6GAVLD98nw="
      ];
    };

    programs = {

      # Enable the Umbriel compositor and its screen-sharing portal
      umbriel.enable = true;

      # Enable the Noctalia shell
      noctalia = {
        enable = true;

        # Only autostart inside Umbriel so other desktops are unaffected
        systemd = {
          enable = true;
          target = "umbriel-session.target";
        };

        # NetworkManager, Bluetooth, UPower and power profiles for the shell's widgets
        recommendedServices.enable = true;
      };
    };

    # Enable the Noctalia login manager
    services.displayManager.noctalia-greeter = {
      enable = true;
      passwordless-sync-users = lib.mkDefault (
        lib.attrNames (lib.filterAttrs (_: user: user.isNormalUser) config.users.users)
      );
    };
  };
}
