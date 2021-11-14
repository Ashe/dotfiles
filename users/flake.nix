{
  description = "User configuration flake";
  inputs = {
    home-manager.url = "github:nix-community/home-manager";
    nur.url = "github:nix-community/NUR";
  };
  outputs = { self, nur, ... }@inputs: let overlays = [ nur.overlay ]; in {
    homeConfigurations = {
      nixos = inputs.home-manager.lib.homeManagerConfiguration {
        username = "ashe";
        homeDirectory = "/home/ashe";
        system = "x86_64-linux";
        configuration.imports = [ ./home.nix ];
      };
    };
  };
}
