# TODO: remove this and replace to nixpkgs after releasing NixOS 25.11
{ pkgs, prev, ... }:
prev.zulu17.override {
  dists.x86_64-linux = { # for tools.
    enableJavaFX = true;
    zuluVersion = "25.32.21";
    jdkVersion = "25.0.2";
    hash = "sha256-lGrZdm2Y/Gq0laGhIAchl9tUmX9pJfuWaA8ezVWR204=";
  };
}
