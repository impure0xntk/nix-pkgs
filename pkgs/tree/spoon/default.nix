# TODO: not working...WIP
{ pkgs, lib, ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "spoon";
  version = "10.4.2";
  src = pkgs.fetchurl {
    url = "https://repo1.maven.org/maven2/fr/inria/gforge/spoon/spoon-core/${version}/spoon-core-${version}-jar-with-dependencies.jar";
    hash = "sha256-aaUDjwCpenHROLTLpCwbdMitZTpCO1sgxAxNXPiEJUQ=";
  };
  buildInputs = with pkgs; [
    temurin-bin-21
    fontconfig
  ];
  nativeBuildInputs = [ pkgs.makeWrapper ];
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/{bin,share}
    cp $src $out/share/spoon.jar

    makeWrapper "${pkgs.temurin-bin-21}/bin/java" $out/bin/spoon \
      --set JAVA_HOME "${pkgs.temurin-bin-21}" \
      --set FONTCONFIG_FILE "${pkgs.fontconfig.out}/etc/fonts/fonts.conf" \
      --add-flags "-classpath $out/share/spoon.jar" \
      --add-flags "spoon.Launcher"
  '';
  meta = with pkgs.lib; {
    homepage = "https://github.com/INRIA/spoon";
    description = "Spoon is a metaprogramming library to analyze and transform Java source code. 🥄 is made with ❤️, 🍻 and ✨. It parses source files to build a well-designed AST with powerful analysis and transformation API.";
    license = with licenses; [mit];
    platforms = platforms.linux;
  };
}
