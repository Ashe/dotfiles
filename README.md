# Dotfiles

## Useful commands

### Restart nix-daemon

```sh
sudo systemctl restart nix-daemon.service
```

### Activate home-manager config from scratch

```sh
NIX_CONFIG="experimental-features = nix-command flakes" nix run home-manager/master -- switch --flake .#CONFIG
```

### Activate specific home-manager config with `nh`

```sh
nh home switch . -c CONFIG
```
