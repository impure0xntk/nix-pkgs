# https://nix.dev/tutorials/callpackage.html
# callPackage passes an attribute from the pkgs attribute set if it exists.
#
# Ref:
#   https://github.com/NixOS/nixpkgs/blob/master/pkgs/top-level/all-packages.nix
#
attrs@{pkgs, lib, ...}:
let
  args = import ./top-level attrs;

  genOverlayPackages = path: finalPkgs: args:
    let
      packageList = lib.my.listDirs { inherit path; };
      packages = builtins.listToAttrs (
        map ( v: { name = baseNameOf v; value = (finalPkgs.callPackage v args); } )
        packageList);
    in packages;

  # TODO: callPackage instead.
  treePkgs = genOverlayPackages ./tree pkgs args;
in
  treePkgs
