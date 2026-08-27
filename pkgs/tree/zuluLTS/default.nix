# TODO: remove this and replace to nixpkgs after releasing NixOS 25.11
{ pkgs, prev, ... }:
prev.zulu17.override {
  dists.x86_64-linux = { # for tools.
    enableJavaFX = true;
    zuluVersion = "25.36.15";
    jdkVersion = "25.0.4";
    hash = "sha256-5Hb1yYlSyzZcp3qBTb48dDQeca520ah9HAppx9KxstA=";
  };
}
