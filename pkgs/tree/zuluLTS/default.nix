# TODO: remove this and replace to nixpkgs after releasing NixOS 25.11
{ pkgs, prev, ... }:
prev.zulu17.override {
  dists.x86_64-linux = { # for tools.
    enableJavaFX = true;
    zuluVersion = "25.30.17";
    jdkVersion = "25.0.1";
    hash = "sha256-Rxs+Yr3/rtJ+NwBdhC2GOfENJEzM4cfN6/erzgbIMT4=";
  };
}
