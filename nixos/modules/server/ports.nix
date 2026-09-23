{
  adguard = {
    web = 3000;
    dns = 53;
  };
  cockpit = 9090;
  forgejo = 3030;
  homepage = 3020;
  mealie = 9925;
  qbittorrent = 8090;
  uptimeKuma = 3001;

  grafana = {
    web = 3240;
    loki = 3241;
    alloy = 12345;
    victoriametrics = 3260;
    smartctlExporter = 3263;
    lokiGrpc = 9096;
  };

  ssh = {
    local = 22;
    public = 2222;
  };

  tangled = {
    web = 7820;
    ssh = 2222;
  };

  # Defaults without a non-breaking custom override interface.
  arrstack = {
    prowlarr = 9696;
    sonarr = 8989;
    radarr = 7878;
    cleanuparr = 11011;
    byparr = 8191;
  };
  jellyfin = 8096;
  wireguard.health = 9999;

  # Platform or upstream listeners, not application backend options.
  caddy = {
    http = 80;
    https = 443;
    admin = 2019;
  };
  crowdsec = {
    api = 8080;
    metrics = 6060;
  };
  ddclient.check = 9099;
  dropbox = 17500;
  tailscale = 41641;
}
