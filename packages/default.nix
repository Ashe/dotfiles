inputs: let pkgs = inputs.nixpkgs.legacyPackages; in {
  "x86_64-linux" = {
    scripts = pkgs."x86_64-linux".callPackage ./scripts {};
    firebot = pkgs."x86_64-linux".callPackage ./firebot {};
  };
}
