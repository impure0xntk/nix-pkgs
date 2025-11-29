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
  generalPackagesOverlay = import ./general-packages;
  javaPackagesOverlay = import ./java-packages.nix;
  nodePackagesOverlay = import ./node-packages;
  pythonPackagesOverlay = import ./python-packages;

  customOverlays = [
    pureOverlay

    my
    generalPackagesOverlay
    javaPackagesOverlay
    nodePackagesOverlay
    (pythonPackagesOverlay {
      uv2nix = inputs.uv2nix;
      pyproject-nix = inputs.pyproject-nix;
      pyproject-build-systems = inputs.pyproject-build-systems;
    })
  ];
in customOverlays
