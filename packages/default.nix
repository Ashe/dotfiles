inputs: let pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux; in {

  # Bundle scripts and add to path
  scripts = pkgs.callPackage ./scripts {};
}
