# TODO: remove this and replace to nixpkgs after releasing NixOS 25.05
{ pkgs, lib, zulujdk ? pkgs.zulu, ... }:
let
in
  assert lib.assertMsg (lib.hasPrefix "zulu" zulujdk.pname) "input non zulu jdk: ${zulujdk.pname}";
(pkgs.jre_minimal.override {
  jdk = zulujdk;
  }).overrideAttrs (old: {
    # for patch binary
    nativeBuildInputs = zulujdk.nativeBuildInputs; # for wrapprogram
    preFixup = zulujdk.preFixup;
    postFixup = zulujdk.postFixup;
  })
