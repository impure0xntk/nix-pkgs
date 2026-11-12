# TODO: remove after bumped memos in nixpkgs
{ pkgs, lib, ... }:

let
  pnpm = pkgs.pnpm_11;
  src = pkgs.fetchFromGitHub {
    owner = "usememos";
    repo = "memos";
    rev = "26.11.0";
    hash = "sha256-Ng9S9BKLyB/KuqeIk6AEs7FLu1gPWreeSAq/WdCc9YQ=";
  };
in
pkgs.stdenvNoCC.mkDerivation {
  pname = "memos-web";
  version = "26.11.0";
  inherit src;
  pnpmDeps = pkgs.fetchPnpmDeps {
    pname = "memos-web";
    version = "26.11.0";
    inherit pnpm src;
    sourceRoot = "${src.name}/web";
    fetcherVersion = 4;
    hash = "sha256-qX5WWPsi8sKPkXPBR48RYXncLytsxfLwkqvivBO0WmY=";
  };
  pnpmRoot = "web";
  nativeBuildInputs = [
    pkgs.nodejs
    pkgs.pnpmConfigHook
    pnpm
  ];
  buildPhase = ''
    runHook preBuild
    pnpm -C web build
    runHook postBuild
  '';
  installPhase = ''
    runHook preInstall
    cp -r web/dist $out
    runHook postInstall
  '';
  meta = with lib; {
    homepage = "https://usememos.com";
    description = "memos frontend assets";
    license = licenses.mit;
    maintainers = [ ];
  };
}
