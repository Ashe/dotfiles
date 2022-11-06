inputs: {
  mkSystem = import ./make-system.nix inputs;
  mkHome = import ./make-home.nix inputs;
  nixosConfigurationsAsPackages = import ./nixos-configurations-as-packages.nix inputs;
  homeConfigurationsAsPackages = import ./home-configurations-as-packages.nix inputs;
}
