{ self, ... }@inputs:
user: host: system:

let
  config-file = import "${self}/home/configurations/${user}@${host}.nix";
  isDarwin = inputs.nixpkgs.lib.hasSuffix "darwin" system;
  home-directory = if isDarwin then "/Users/${user}" else "/home/${user}";

in
inputs.home-manager.lib.homeManagerConfiguration {
  pkgs = inputs.nixpkgs.legacyPackages.${system};
  extraSpecialArgs = {
    inherit inputs;
    shared-lib = import ./shared;
  };
  modules = self.homeModules ++ [
    config-file
    inputs.nur.modules.homeManager.default
    inputs.zen-browser.homeModules.default
    {
      home = {
        username = user;
        homeDirectory = home-directory;
        packages = with inputs.nixpkgs.legacyPackages.${system}; [
          magic-wormhole-rs
          netcat
        ];
      };
      nix = {
        package = inputs.nixpkgs.legacyPackages.${system}.lixPackageSets.stable.lix;
        settings.experimental-features = [
          "nix-command"
          "flakes"
        ];
      };
      programs = {
        home-manager.enable = true;
        git.enable = inputs.nixpkgs.lib.mkDefault true;
        git.signing.format = null;
        jujutsu.enable = inputs.nixpkgs.lib.mkDefault true;
        nh.enable = inputs.nixpkgs.lib.mkDefault true;
        nix-your-shell.enable = inputs.nixpkgs.lib.mkDefault true;
      };
    }
  ];
}
