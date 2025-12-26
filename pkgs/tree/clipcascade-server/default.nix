{ pkgs, lib, ...}:
let
  jre21 = pkgs.temurin-bin-21;
in
pkgs.maven.buildMavenPackage rec {
  pname = "clipcascade-server";
  version = "3.1.0";
  src = "${pkgs.fetchFromGitHub {
    owner = "Sathvik-Rao";
    repo = "ClipCascade";
    rev = "v${version}";
    hash = "sha256-+csAEPCdPHxWz7gp4ES4r5bOnVUKDw3oo8lt4MXqKyo=";
  }}/ClipCascade_Server/ClipCascade_Backend";

  mvnJdk = jre21;
  mvnHash = "sha256-iN720c0H00YBw0r9YP61Gc1U2zyq44kojovju2gXREQ=";

  nativeBuildInputs = with pkgs;[ makeWrapper ];

  patches = [
    ./host-address.patch
  ];

  doCheck = false;

  installPhase = ''
    mkdir -p $out/bin $out/share/clipcascade-server
    install -Dm644 target/ClipCascade-Server-JRE_21.jar $out/share/clipcascade-server

    makeWrapper ${jre21}/bin/java $out/bin/clipcascade-server \
      --add-flags "-jar $out/share/clipcascade-server/ClipCascade-Server-JRE_21.jar"
  '';

  meta = with lib; {
    description = "ClipCascade is a lightweight utility that automatically syncs the clipboard across devices, no key press required.";
    homepage = "https://github.com/Sathvik-Rao/ClipCascade";
    license = licenses.gpl3;
    mainProgram = "clipcascade-server";
  };
}

