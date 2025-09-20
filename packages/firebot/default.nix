{ stdenv, pkgs }:

stdenv.mkDerivation {
  name = "firebot-5.64.0";

  # Download the release tarball and automatically unpack .tar.gz
  src = pkgs.fetchurl {
    url = "https://github.com/crowbartools/Firebot/releases/download/v5.64.0/Firebot-v5.64.0-linux-x64.tar.gz";
    sha256 = "sha256-bUwAx0SMEQ4NXfTi6To++v1W24n/mMpjzBK6sN0ayJc=";
  };

  # Force creation of a specific directory
  dontUnpack = true;

  installPhase = ''
    # Create the target directory first
    mkdir -p $out/share/firebot

    # Extract directly into the target directory
    tar -xzf $src -C $out/share/firebot

    # Create the symlink
    mkdir -p $out/bin
    ln -sf $out/share/firebot/"Firebot v5" $out/bin/firebot
    chmod +x $out/share/firebot/"Firebot v5"
  '';
}
