{ pkgs,
  jdk,
  ... }:
let
in pkgs.stdenv.mkDerivation rec {
  pname = "UMLDoclet";
  version = "2.2.1";
  src = pkgs.fetchurl {
    url = "https://repo1.maven.org/maven2/nl/talsmasoftware/umldoclet/${version}/umldoclet-${version}.jar";
    hash = "sha256-B3TBxUKeyqUuIPFS51JKQcn1BqH6lT1zFbqYm3XUtcg=";
  };
  buildInputs = [ jdk ];
  phases = ["installPhase"];
  installPhase = ''
    mkdir -p $out/share
    cp $src $out/share/umldoclet.jar
  '';

  meta = with pkgs.lib; {
    homepage = "https://github.com/talsma-ict/umldoclet";
    description = "Doclet for the JavaDoc tool that generates UML diagrams from the code.";
    license = with licenses; [asl20];
    platforms = platforms.linux;
  };
}

