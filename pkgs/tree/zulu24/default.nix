# TODO: remove this and replace to nixpkgs after releasing NixOS 25.11
{ pkgs, prev, ... }:
prev.zulu24.override {
  dists.x86_64-linux = { # for tools.
    zuluVersion = "24.30.11";
    jdkVersion = "24.0.1";
    hash = "sha256-EvaVfDoqdNNtaSz+467rlJ8VtdgNrQi/DT7ZMNZthlk=";
  };
}
