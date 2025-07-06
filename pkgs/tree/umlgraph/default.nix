{ pkgs,
  jdk ? pkgs.zulu8,
  ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "umlgraph";
  version = "5.7_2.32";
  src = pkgs.fetchurl { # small
    url = "https://www.spinellis.gr/umlgraph/jars/UmlGraph-${version}-SNAPSHOT.jar";
    hash = "sha256-wGAmAT64ocYDLYLPxl41/MkVSnDycq0CAY/QJvziRfA=";
  };
  buildInputs = [ jdk ];
  nativeBuildInputs = [ pkgs.makeWrapper ];
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/{bin,share}
    # cp $src/UmlGraph-${version}-SNAPSHOT.jar $out/share/umlgraph.jar
    cp $src $out/share/umlgraph.jar

    makeWrapper "${jdk}/bin/java" $out/bin/umlgraph \
      --set JAVA_HOME ${jdk} \
      --add-flags "-cp $out/share/umlgraph.jar:${jdk}/lib/tools.jar"

    # requires jdk8 (not jre, and < jdk9)
    test -f ${jdk}/lib/tools.jar
  '';

  # TODO: check license.
  meta = with pkgs.lib; {
    homepage = "https://byteman.jboss.org/index.html";
    description = "Simplify Java tracing, monitoring and testing with Byteman";
    # license = with licenses; [asl20];
    platforms = platforms.linux;
  };
}
