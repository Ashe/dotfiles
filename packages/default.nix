inputs: let pkgs = inputs.nixpkgs.legacyPackages; in {
  "x86_64-linux" = {
    firebot = pkgs."x86_64-linux".callPackage ./firebot {};
  };
}
