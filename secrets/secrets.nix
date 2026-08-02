let
  inherit (builtins) readDir readFile attrNames;
  inherit (import <nixpkgs/lib>) filterAttrs foldl;

  # Read the public key for a given machine directory
  readKey = dir: readFile ./${dir}/key.pub;

  # Find all subdirectories of secrets/ — each represents a machine
  dirs = attrNames (filterAttrs (_: type: type == "directory") (readDir ./.));
in
# For each machine directory, declare the expected secrets
foldl (
  acc: dir:
  acc
  // {
    "${dir}/adguard-key.age".publicKeys = [ (readKey dir) ];
    "${dir}/configarr-secrets.age".publicKeys = [ (readKey dir) ];
    "${dir}/crowdsec-bouncer-key.age".publicKeys = [ (readKey dir) ];
    "${dir}/crowdsec-enrollment-key.age".publicKeys = [ (readKey dir) ];
    "${dir}/ddclient-porkbun.age".publicKeys = [ (readKey dir) ];
    "${dir}/forgejo-credentials.age".publicKeys = [ (readKey dir) ];
    "${dir}/freshrss-secrets.age".publicKeys = [ (readKey dir) ];
    "${dir}/grafana-key.age".publicKeys = [ (readKey dir) ];
    "${dir}/homepage-secrets.age".publicKeys = [ (readKey dir) ];
    "${dir}/qbittorrent-credentials.age".publicKeys = [ (readKey dir) ];
    "${dir}/tangled-secrets.age".publicKeys = [ (readKey dir) ];
    "${dir}/uptime-kuma-credentials.age".publicKeys = [ (readKey dir) ];
    "${dir}/wireguard-conf.age".publicKeys = [ (readKey dir) ];
  }
) { } dirs
