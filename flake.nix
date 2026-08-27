{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
    nixgl.url = "github:nix-community/nixGL";
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tangled = {
      url = "git+https://tangled.org/tangled.org/core";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    llm-agents.url = "github:numtide/llm-agents.nix";
    hytale-launcher.url = "github:JPyke3/hytale-launcher-nix";
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
