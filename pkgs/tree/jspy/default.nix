# TODO: not working...WIP
{ pkgs,
  jdk,
  ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "jspy";
  version = "3.0.1";
  src = pkgs.fetchurl { # small
    url = "https://github.com/nokia/jspy/releases/download/v${version}/jSpy.jar";
    hash = "sha256-e65YhwBvE25Ny5SdaSCBUOSWu3RTBcfKNqxzX69WE98=";
  };
  buildInputs = [
    jdk
    pkgs.fontconfig
  ];
  nativeBuildInputs = [ pkgs.makeWrapper ];
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/{bin,share}
    cp $src $out/share/jSpy.jar

    makeWrapper "${jdk}/bin/java" $out/bin/jspy \
      --set JAVA_HOME "${jdk}" \
      --set FONTCONFIG_FILE "${pkgs.fontconfig.out}/etc/fonts/fonts.conf" \
      --add-flags "-jar $out/share/jSpy.jar"
  '';
  meta = with pkgs.lib; {
    homepage = "https://github.com/nokia/jspy";
    description = "Tool which displays the component properties of any java Swing application.";
    license = with licenses; [asl20];
    platforms = platforms.linux;
  };
}
