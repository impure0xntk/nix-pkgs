# TODO: remove this and replace to nixpkgs after releasing NixOS 25.11
{ pkgs, prev, ... }:
prev.zulu17.override {
  dists.x86_64-linux = { # for tools.
    enableJavaFX = true;
    zuluVersion = "25.34.17";
    jdkVersion = "25.0.3";
    hash = "sha256-OpMjX05bMTIyZHkWIZ6R3FzKC5g1ybUqQEuljENXFpc=";
  };
}
