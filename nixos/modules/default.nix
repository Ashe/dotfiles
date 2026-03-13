{
  nix = import ./nix;
  server = import ./server;
  adguard = import ./adguard;
  caddy = import ./caddy;
  cockpit = import ./cockpit;
  dropbox = import ./dropbox;
  jellfyin = import ./jellyfin;
  mullvad = import ./mullvad;
  steam = import ./steam;
  tailscale = import ./tailscale;
}
