{ self, ... } @ inputs: user: host: system:

let
  config-file = import "${self}/home/configurations/${user}@${host}.nix" inputs;
  home-directory = "/home/${user}";

in inputs.home-manager.lib.homeManagerConfiguration {
  pkgs = inputs.nixpkgs.legacyPackages.${system};
  modules = builtins.attrValues self.homeModules ++ [
    config-file
    inputs.nur.nixosModules.nur
    {
      home = {
        username = user;
        homeDirectory = home-directory;
      };
    }
  ];
}
