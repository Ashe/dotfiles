{ stdenv
, lib
, fetchFromGitHub
, libpng
, libjpeg_turbo
, libvorbis
, openal
, SDL2
, sqlite
, mbedtls
, libuv
, libGLU
, pcre
}:

stdenv.mkDerivation rec {
  pname = "hashlink";
  version = "1.12";

  src = fetchFromGitHub {
    owner = "HaxeFoundation";
    repo = "hashlink";
    rev = version;
    sha256 = "AiUGhTxz4Pkrks4oE+SAuAQPMuC5T2B6jo3Jd3sNrkQ=";
  };

  buildInputs = [ libpng libjpeg_turbo libvorbis openal SDL2 sqlite mbedtls libuv libGLU pcre ];

  makeFlags = [ "PREFIX=$(out)" ];

  meta = with lib; {
    description = "A virtual machine for Haxe";
    homepage = "https://hashlink.haxe.org/";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = with maintainers; [ iblech ];
  };
}
