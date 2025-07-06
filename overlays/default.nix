# Inspire: https://github.com/tiredofit/home/blob/main/overlays/default.nix
{inputs, lib, pkgsPath, ...}:
let
  my = final: prev: import pkgsPath {
    inherit lib prev;
    pkgs = final;
  };
  javaPackagesOverlay = import ./java-packages.nix;
  nodePackagesOverlay = import ./node-packages.nix;
  pythonPackagesOverlay = import ./python-packages;

  customOverlays = [
    my
    javaPackagesOverlay
    nodePackagesOverlay
    (pythonPackagesOverlay { 
      uv2nix = inputs.uv2nix;
      pyproject-nix = inputs.pyproject-nix;
      pyproject-build-systems = inputs.pyproject-build-systems;
    })
  ];
in customOverlays
