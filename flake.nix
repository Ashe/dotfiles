{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
    nixgl.url = "github:nix-community/nixGL";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lobster.url = "github:justchokingaround/lobster";
  };
  outputs = inputs: {

    # System configurations and modules
    nixosConfigurations = import ./nixos/configurations inputs;
    nixosModules = import ./nixos/modules;

    # Home-manager configurations and modules
    homeConfigurations = import ./home/configurations inputs;
    homeModules = import ./home/modules;

    # Custom library functions
    lib = import ./lib inputs;

    # Packages to build
    packages = import ./packages inputs;
  };
}
