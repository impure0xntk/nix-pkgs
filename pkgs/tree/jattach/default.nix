{ pkgs,
  ... }:
let
  version = "2.2";
in pkgs.stdenv.mkDerivation {
  pname = "jattach";
  version = version;
  src = pkgs.fetchzip { # depends no dynamic libraries
    url = "https://github.com/jattach/jattach/releases/download/v${version}/jattach-linux-x64.tgz";
    hash = "sha256-XZ7CpTdY+JTr3FbXHEquHXhAErKbbn9l3UJyDsrpBOg=";
  };
  installPhase = ''
    mkdir -p $out/bin
    cp -r $src/jattach $out/bin
  '';
  meta = with pkgs.lib; {
    homepage = "https://github.com/jattach/jattach";
    description = "JVM Dynamic Attach utility";
    license = with licenses; [asl20];
    platforms = platforms.linux;
  };
}
