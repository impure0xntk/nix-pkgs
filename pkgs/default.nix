# https://nix.dev/tutorials/callpackage.html
# callPackage passes an attribute from the pkgs attribute set if it exists.
#
# Ref:
#   https://github.com/NixOS/nixpkgs/blob/master/pkgs/top-level/all-packages.nix
#
attrs@{pkgs, lib, pkgs-unstable ? null, ...}:
let
  args = import ./top-level attrs;

  genOverlayPackages = path: finalPkgs: args:
    let
      packageList = lib.my.listDirs { inherit path; };
      packages = builtins.listToAttrs (
        map ( v: { name = baseNameOf v; value = (finalPkgs.callPackage v args); } )
        packageList);
    in packages;

  # Build tree packages with access to unstable and pythonOverlay
  treeArgs = args // (lib.optionalAttrs (pkgs-unstable != null) { inherit pkgs-unstable; });
  treePkgs = genOverlayPackages ./tree pkgs treeArgs;
in
  treePkgs
