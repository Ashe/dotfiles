{ self, ... } @ inputs: {

  # Bundle scripts and add to path
  scripts = inputs.nixpkgs.callPackage ./packages/scripts {};
}
