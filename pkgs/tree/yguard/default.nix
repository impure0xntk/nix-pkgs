{ pkgs,
  jdk,
  ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "yguard";
  version = "4.0.0";
  src = pkgs.fetchurl {
    url = "https://repo1.maven.org/maven2/com/yworks/yguard/${version}/yguard-${version}.jar";
    hash = "sha256-FIgJDqY0VxuOQt8K5h5zVywBfpyqveeAh78bWz/yvSo=";
  };
  buildInputs = [
    jdk
  ];
  nativeBuildInputs = [ pkgs.makeWrapper ];
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/{bin,share}
    cp $src $out/share/yguard.jar

    makeWrapper "${jdk}/bin/java" $out/bin/yguard \
      --set JAVA_HOME "${jdk}" \
      --add-flags "-jar $out/share/yguard.jar"
  '';
  meta = with pkgs.lib; {
    homepage = "https://github.com/yWorks/yGuard";
    description = "The open-source Java obfuscation tool working with Ant and Gradle by yWorks - the diagramming experts";
    license = with licenses; [mit];
    platforms = platforms.linux;
  };
}
