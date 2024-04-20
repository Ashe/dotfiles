{ inputs, config, lib, pkgs, ... }:

{
  # Add options for mullvad, a vpn
  options.mullvad.enable = lib.mkEnableOption "mullvad";

  # Install mullvad if desired
  config = lib.mkIf config.mullvad.enable {

    # Enable mullvad
    services.mullvad-vpn.enable = true;

    # Install programs related to mullvad
    environment.systemPackages = with pkgs; [

      # Desktop client for mullvad
      mullvad-vpn
    ];
  };
}
