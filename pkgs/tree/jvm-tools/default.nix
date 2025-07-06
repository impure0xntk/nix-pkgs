# https://bell-sw.com/announcements/2021/10/14/jcmd-everywhere-locally-containerized-and-remotely/
{ pkgs,
  jdk,
  ... }:
let
  # TODO: WIP
  # completionBash = ./sjk.bash;
  # completionFish = ./sjk.fish;
in pkgs.stdenv.mkDerivation rec {
  pname = "jvm-tools";
  version = "0.23";
  src = pkgs.fetchurl {
    url = "https://repo1.maven.org/maven2/org/gridkit/jvmtool/sjk-plus/${version}/sjk-plus-${version}.jar";
    hash = "sha256-aqsHzfDsrTlOIlofR9c0LLI7/Yt9XGXJRfgYNTY+yTc=";
  };
  buildInputs = [ jdk ];
  nativeBuildInputs = [ pkgs.makeWrapper pkgs.installShellFiles ];
  phases = ["installPhase" "postInstall"];
  installPhase = ''
    mkdir -p $out/{bin,share}
    cp $src $out/share/sjk.jar

    makeWrapper "${jdk}/bin/java" $out/bin/sjk \
      --set JAVA_HOME ${jdk} \
      --add-flags "-jar $out/share/sjk.jar"
  '';
  postInstall = ''
    # TODO: WIP
    # installShellCompletion --bash {completionBash}
    # installShellCompletion --fish {completionFish}
  '';

  meta = with pkgs.lib; {
    homepage = "https://github.com/aragozin/jvm-tools";
    description = "Small set of tools for JVM troublshooting, monitoring and profiling.";
    license = with licenses; [asl20];
    platforms = platforms.linux;
  };
}

