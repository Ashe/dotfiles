{ stdenv }:

# Make scripts in src accessible to path
stdenv.mkDerivation {
  pname = "home-scripts";
  version = "1";
  src = ./scripts;
  dontBuild = true;
  installPhase = ''
    mkdir -p $out/bin
    install -t $out/bin ./*
  '';
}
