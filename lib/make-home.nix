{ self, ... } @ inputs: user: host: system:

let
  config-file = import "${self}/home/configurations/${user}@${host}.nix";
  home-directory = "/home/${user}";

in inputs.home-manager.lib.homeManagerConfiguration {
  pkgs = inputs.nixpkgs.legacyPackages.${system};
  extraSpecialArgs = { inherit inputs; };
  modules = self.homeModules ++ [
    config-file
    inputs.nur.modules.homeManager.default
    inputs.zen-browser.homeModules.default
    {
      home = {
        username = user;
        homeDirectory = home-directory;
        packages = with inputs.nixpkgs.legacyPackages."x86_64-linux"; [
          magic-wormhole-rs
          netcat
        ];
      };
      nix = {
        package = inputs.nixpkgs.legacyPackages.${system}.nix;
        settings.experimental-features = [ "nix-command" "flakes" ];
      };
      programs.home-manager.enable = true;
      programs.git.enable = inputs.nixpkgs.lib.mkDefault true;
    }
  ];
}
