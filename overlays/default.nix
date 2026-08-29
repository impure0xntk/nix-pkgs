# Inspire: https://github.com/tiredofit/home/blob/main/overlays/default.nix
{inputs, system, lib, pkgsPath, ...}:
let
  myOverlay = final: prev:
  let
    purePkgsOptions = {
      inherit (final) system;
      config.allowUnfree = true;
    };

    # stable/unstable uses to avoid unnecessary python build
    stable = import inputs.nixpkgs purePkgsOptions;
    unstable = import inputs.nixpkgs-unstable purePkgsOptions;

    bun2nixOverlayResult = inputs.bun2nix.overlays.default final prev;
  in {
    my = let
      # Java packages (jdk, zulu, etc.)
      javaPkgs = (import ./java-packages.nix) final prev;

      # Python overlay configuration
      pythonOverlayFunc = (import ./python-packages {
        uv2nix = inputs.uv2nix;
        pyproject-nix = inputs.pyproject-nix;
        pyproject-build-systems = inputs.pyproject-build-systems;
      });
      pythonOverlayResult = pythonOverlayFunc final prev;

      bun2nixOverlayResult = inputs.bun2nix.overlays.default final prev;

      # Apply python overlay to pkgs so treePkgs uses overlaid python
      pkgsWithOverlays = final // javaPkgs // pythonOverlayResult // bun2nixOverlayResult;
      # Tree packages with access to overlaid pkgs, unstable, and other attributes
      treePkgs = import pkgsPath {
        inherit lib prev;
        pkgs = pkgsWithOverlays;
      };
    in
      treePkgs // javaPkgs;
    inherit stable unstable;
  }
  // bun2nixOverlayResult;
in myOverlay
