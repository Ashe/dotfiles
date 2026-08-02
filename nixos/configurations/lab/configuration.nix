{
  inputs,
  pkgs,
  ...
}:

{

  ##################
  # Custom modules #
  ##################

  server = {
    ip = "192.168.1.198";
    domain = "lab";
    publicDomain = "aas.sh";
  };

  agenix.secrets = "${inputs.self}/secrets/lab";

  ssh.enable = true;
  adguard.enable = true;
  arrstack.enable = true;
  caddy.enable = true;
  cockpit.enable = true;
  crowdsec.enable = true;
  ddclient.porkbun.enable = true;
  forgejo.enable = "local";
  freshrss.enable = true;
  grafana.enable = true;
  homepage.enable = true;
  mealie.enable = "local";
  jellyfin.enable = "public";
  qbittorrent.enable = true;
  tailscale.enable = true;
  tangled.enable = "local";
  uptime-kuma.enable = true;
  wireguard.enable = true;

  ##################
  # Configurations #
  ##################

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "lab";

  # Configure network connections interactively with nmcli or nmtui.
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.root.initialPassword = "nixos";
  users.users.ashe = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFZ6rqJxjy/EIKRvf43R1KwhL4cEZs6fXuGEQmecBT3p ashe@tomoe"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII3VhqBFpEMxrVA5eq8w/q8lnV/IYutBXcZN5Voxnb0w deck@steamdeck"
    ];
  };

  # Install packages
  environment.systemPackages = with pkgs; [
    openssl
    jujutsu
  ];

  # Enable Intel QSV
  hardware = {
    enableAllFirmware = true;
    graphics = {
      enable = true;
      extraPackages = with pkgs; [
        intel-media-driver
        vpl-gpu-rt
      ];
    };
  };

  # Tell jellyfin to use intel drivers
  systemd.services.jellyfin.environment.LIBVA_DRIVER_NAME = "iHD";

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # TODO: UDP GRO forwarding warning from Tailscale on enp2s0
  # Known NixOS issue, fix is unreliable - revisit later
  # https://tailscale.com/s/ethtool-config-udp-gro
  # https://github.com/NixOS/nixpkgs/issues/411980

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.11"; # Did you read the comment?

}
