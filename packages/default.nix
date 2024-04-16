inputs: let pkgs = inputs.nixpkgs.legacyPackages; in {

  # User-made packages
  "x86_64-linux" = {

    # Bundle scripts and add to path
    scripts = pkgs."x86_64-linux".callPackage ./scripts {};
  };
}
