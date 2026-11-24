# TODO: remove after bumped memos in nixpkgs
{ pkgs, lib, ... }:

let
  version = "26.11.2";
  memos-web = pkgs.my.memos-web;
in
pkgs.buildGo127Module {
  pname = "memos";
  version = version;
  src = pkgs.fetchFromGitHub {
    owner = "usememos";
    repo = "memos";
    rev = version;
    hash = "sha256-R3Ui4y8wjZdaIuUrY6Bjuio4TGaZgnkFfRYV0xuR6n4=";
  };
  vendorHash = "sha256-w1tCEuLbbTG+xrIx+Rij3kqsjxjRFoKov0+SDdvZUQ4=";
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
