# Inspire: https://github.com/tiredofit/home/blob/main/overlays/default.nix
{
  inputs,
  system,
  lib,
  pkgsPath,
  ...
}:
let
  myOverlay =
    final: prev:
    let
      purePkgsOptions = {
        inherit (final) system;
        config.allowUnfree = true;
      };

      stable = import inputs.nixpkgs purePkgsOptions;
      unstable = import inputs.nixpkgs-unstable purePkgsOptions;

      # nixpkgs-multiverse: access every nixpkgs revision's packages via pkgs.multiverse
      multiverse = inputs.nix-multiverse.legacyPackages.${system};

      javaPkgs = (import ./java-packages.nix) final prev;

      pythonOverlayFunc = (
        import ./python-packages {
          uv2nix = inputs.uv2nix;
          pyproject-nix = inputs.pyproject-nix;
          pyproject-build-systems = inputs.pyproject-build-systems;
        }
      );
      pythonOverlayResult = pythonOverlayFunc final prev;

      bun2nixOverlayResult = inputs.bun2nix.overlays.default final prev;

      zedOverlayResult = inputs.zed-extensions.overlays.default final prev;

      pkgsWithOverlays = final // javaPkgs // pythonOverlayResult // bun2nixOverlayResult // zedOverlayResult;

      my = (import pkgsPath {
        inherit lib prev;
        pkgs = pkgsWithOverlays;
        uvPkgs = pkgsWithOverlays;
      }) // {
        multiverse = multiverse;
      };
    in
    {
      my = my;
      inherit stable unstable;
      multiverse = multiverse;
    };
in
myOverlay
