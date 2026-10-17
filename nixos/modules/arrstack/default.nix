{
  config,
  lib,
  ...
}:

{
  imports = [
    ./shelfmark.nix
    ./sonarr.nix
    ./radarr.nix
    ./prowlarr.nix
    ./cleanuparr.nix
    ./byparr.nix
    ./configarr.nix
  ];

  options.arrstack.enable = lib.mkEnableOption "arrstack";

  config = lib.mkIf config.arrstack.enable {

    users.users.arrstack = {
      isSystemUser = true;
      uid = 990;
      group = "arrstack";
      home = "/var/lib/arrstack";
      createHome = true;
      extraGroups = [ "qbittorrent" ];
      linger = true;
      subUidRanges = [
        {
          startUid = 100000;
          count = 65536;
        }
      ];
      subGidRanges = [
        {
          startGid = 100000;
          count = 65536;
        }
      ];
    };

    users.groups.arrstack = {
      gid = 990;
    };

    systemd.tmpfiles.rules = [
      "d /data/media 0755 arrstack arrstack -"
      "d /data/media/movies 0755 arrstack arrstack -"
      "d /data/media/shows 0755 arrstack arrstack -"
      "d /data/media/anime 0755 arrstack arrstack -"
      "d /data/media/music 0755 arrstack arrstack -"
    ];

    # Shared podman network for the containerised services
    systemd.services.arrstack-network = {
      description = "Create arrstack Podman network";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = "arrstack";
        ExecStart = "/bin/sh -c '${config.virtualisation.podman.package}/bin/podman network create arrstack || true'";
      };
    };
  };
}
