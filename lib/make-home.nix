{ self, ... } @ inputs: user: host: system:

let
  config-file = import "${self}/home/configurations/${user}@${host}.nix" inputs;
  home-directory = "/home/${user}";

in inputs.home-manager.lib.homeManagerConfiguration {
  pkgs = inputs.nixpkgs.legacyPackages.${system};
  extraSpecialArgs = { inherit inputs; };
  modules = self.homeModules ++ [
    config-file
    inputs.nur.nixosModules.nur
    inputs.hyprland.homeManagerModules.default
    {
      home = {
        username = user;
        homeDirectory = home-directory;
        packages = with inputs.nixpkgs.legacyPackages."x86_64-linux"; [
          magic-wormhole-rs
          netcat
        ];
      };
      programs.home-manager.enable = true;
      programs.git.enable = inputs.nixpkgs.lib.mkDefault true;
    }
  ];
}
