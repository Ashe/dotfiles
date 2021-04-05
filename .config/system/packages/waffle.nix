{ lib, fetchFromGitHub }:

fetchFromGitHub {
  name = "bitmap-font-collections";

  owner = "addy-dclxvi";
  repo = "bitmap-font-collections";
  rev = "298e178916d1855bebe22547b3da2500089f3dbd";

  postFetch = ''
    tar xf $downloadedFile --strip=1
    mkdir -p $out/share/fonts/
    cp *.bdf $out/share/fonts/
  '';

  sha256 = "0wgs23hjrqvb4wzh3xzwiq5mg2mhcdnlp6wsgg8wjk0m2lzxgz8q";

  meta = with lib; {
    homepage = "https://addy-dclxvi.github.io/post/bitmap-fonts/";
    description = "A collection of bitmap fonts by Addy";
    license = "gpl-3.0";
    platforms = platforms.all;
  };
}
