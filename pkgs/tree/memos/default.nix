# TODO: remove after bumped memos in nixpkgs
{ pkgs, lib, ... }:

let
  version = "26.11.0";
  memos-web = pkgs.my.memos-web;
in
pkgs.buildGo127Module {
  pname = "memos";
  version = version;
  src = pkgs.fetchFromGitHub {
    owner = "usememos";
    repo = "memos";
    rev = version;
    hash = "sha256-Ng9S9BKLyB/KuqeIk6AEs7FLu1gPWreeSAq/WdCc9YQ=";
  };
  vendorHash = "sha256-CuBQYJ8lDd113SWFDA+nIcULwmWtiTLbbegzfoMgtb4=";
  # release-version tests require `git` runtime not
  # available in build sandbox; skip them.
  doCheck = false;
  ldflags = [
    "-X github.com/usememos/memos/internal/version.Version=${version}"
  ];
  preBuild = ''
    rm -rf server/frontend/dist
    cp -r ${memos-web} server/frontend/dist
  '';
  meta = with lib; {
    homepage = "https://usememos.com";
    description = "Lightweight, self-hosted memo hub";
    license = licenses.mit;
    maintainers = [ ];
    mainProgram = "memos";
  };
}
