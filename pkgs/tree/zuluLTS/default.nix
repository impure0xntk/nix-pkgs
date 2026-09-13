# TODO: remove this and replace to nixpkgs after releasing NixOS 25.11
{ pkgs, ... }:
pkgs.zulu25.override (prev: {
  dists.x86_64-linux = {
    zuluVersion = "25.36.205";
    jdkVersion = "25.0.4.1";
    hash = "sha256-4R2SWJ3o/VVhaoQ+Api6cjSISL1JtnUIjpMLZ1OEl8s=";
  };
})
