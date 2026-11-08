# TODO: remove this and replace to nixpkgs after releasing NixOS 25.11
{ pkgs, ... }:
pkgs.zulu25.override (prev: {
  dists.x86_64-linux = {
    zuluVersion = "25.38.109";
    jdkVersion = "25.0.5.0.3";
    hash = "sha256-u2M7Vm/VAZEahQ1gTX06vf7mV6iPK7rLEuXrw0cnNW8=";
  };
})
