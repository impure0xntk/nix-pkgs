# Inspire: https://github.com/tiredofit/home/blob/main/overlays/default.nix
{inputs, system, lib, pkgsPath, ...}:
let
  pureOverlay = final: prev: {
    pure = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };
    pure-unstable = import inputs.nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    };
  };
  my = final: prev: import pkgsPath {
    inherit lib prev;
    pkgs = final;
  };
  javaPackagesOverlay = import ./java-packages.nix;
  pythonPackagesOverlay = import ./python-packages;

  customOverlays = [
    pureOverlay

    my
    javaPackagesOverlay
    (pythonPackagesOverlay {
      uv2nix = inputs.uv2nix;
      pyproject-nix = inputs.pyproject-nix;
      pyproject-build-systems = inputs.pyproject-build-systems;
    })
  ];
in customOverlays
