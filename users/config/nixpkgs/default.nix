{
  # Mange nixpkgs config file
  xdg.configFile.nixpkgs = {
    source = ./config.nix;
    target = "nixpkgs/config.nix";
  };
}
