# TODO: remove after bumped memos in nixpkgs
{ pkgs, lib, ... }:

let
  pnpm = pkgs.pnpm_11;
  src = pkgs.fetchFromGitHub {
    owner = "usememos";
    repo = "memos";
    rev = "26.11.2";
    hash = "sha256-R3Ui4y8wjZdaIuUrY6Bjuio4TGaZgnkFfRYV0xuR6n4=";
  };
in
pkgs.stdenvNoCC.mkDerivation {
  pname = "memos-web";
  version = "26.11.2";
  inherit src;
  pnpmDeps = pkgs.fetchPnpmDeps {
    pname = "memos-web";
    version = "26.11.2";
    inherit pnpm src;
    sourceRoot = "${src.name}/web";
    fetcherVersion = 4;
    hash = "sha256-WZ+Qg7DOGGq26FJfKvKwwK8U0l+SsjCIY8akLPz22us=";
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
