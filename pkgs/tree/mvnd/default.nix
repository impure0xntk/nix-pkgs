# This includes maven, and specific library for mavend.
# TODO: remove and delefate to pkgs.mvnd after fixing https://github.com/NixOS/nixpkgs/pull/407817
{ pkgs, prev, ... }:
(prev.mvnd.overrideAttrs (new: old: {
  passthru.maven = new.finalPackage.out + "/mvnd-home/mvn";
})).override {
  maven = pkgs.maven;
}
