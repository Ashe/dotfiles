inputs: let pkgs = inputs.nixpkgs.legacyPackages; in {

  # Linux scripts
  x86_64-linux = {

    # Bundle scripts and add to path
    scripts = pkgs.x86_64-linux.callPackage ./scripts {};
  };
}
