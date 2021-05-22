{

  # Extend available packages from nixpkgs
  packageOverrides = pkgs: {

    # Enable the use of the NUR with nix-shell and home-manager
    nur = import (builtins.fetchTarball "https://github.com/nix-community/NUR/archive/master.tar.gz") {
      inherit pkgs;
    };
  };
}
