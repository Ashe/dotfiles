{ nixpkgs, ... }:

{
  # Add overlays to nixpkgs
  nixpkgs.overlays = [

    # Roll back SwayNC while bugged
    (self: super: {
      swaynotificationcenter = super.swaynotificationcenter.overrideAttrs (prev: {
        version = "git";
        src = super.fetchFromGitHub {
          owner = "ErikReider";
          repo = "SwayNotificationCenter";
          rev = "v0.6.1";
          sha256 = "sha256-+vMlhBCLxvqfPRO2U9015srhY/2sd1DoV27kzNDjsqs=";
        };
      });
    })
  ];
}
