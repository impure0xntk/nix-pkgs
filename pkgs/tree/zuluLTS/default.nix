# TODO: remove this and replace to nixpkgs after releasing NixOS 25.11
{ pkgs, prev, ... }:
prev.zulu17.override {
  dists.x86_64-linux = { # for tools.
    zuluVersion = "25.28.85";
    jdkVersion = "25.0.0";
    hash = "sha256-Fk2QHlokC4wYUW9atVvBH8lomrboKQRa6oRnNW3Ns0A=";
  };
}
