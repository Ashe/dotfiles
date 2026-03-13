{ inputs, config, lib, pkgs, ... }:

{
  options.mullvad.enable = lib.mkEnableOption "mullvad";

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
