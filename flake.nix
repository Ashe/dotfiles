{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/NUR";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mesa-git = {
      url = "git+https://gitlab.freedesktop.org/mesa/mesa?ref=main";
      flake = false;
    };
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland-portal.url = "github:hyprwm/xdg-desktop-portal-hyprland";
  };
  outputs = inputs: {

    # System configurations and modules
    nixosConfigurations = import ./nixos/configurations inputs;
    nixosModules = import ./nixos/modules inputs;

    # Home-manager configurations and modules
    homeConfigurations = import ./home/configurations inputs;
    homeModules = import ./home/modules inputs;

    # Custom library functions
    lib = import ./lib inputs;

    # Packages to build
    packages = import ./packages inputs;
  };
}
