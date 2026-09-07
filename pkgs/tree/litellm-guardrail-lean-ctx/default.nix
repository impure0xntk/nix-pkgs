# https://github.com/impure0xntk/LiteLLM-Guardrail-lean-ctx
# Reuse upstream's `nix/package.nix` by calling it through
# `pkgs.python313Packages.callPackage`, which auto-supplies `buildPythonPackage`,
# `hatchling`, and `python313` from the matching Python package set. `litellm`
# is overridden below so we stay inside the unstable package set.
{
  pkgs,
  lib,
  ...
}:
let
  src = pkgs.fetchFromGitHub {
    owner = "impure0xntk";
    repo = "LiteLLM-Guardrail-lean-ctx";
    rev = "82e0ac153562d0cf839cce8b366982fc257849e3"; # main @ 2026-09-08
    hash = "sha256-8VETRb4/lJSDuB3aV5af8oLW96akhjYDKAHHMqX8tbI=";
  };
  pythonPackages = pkgs.unstable.python313Packages;
in
pythonPackages.callPackage "${src}/nix/package.nix" {
  litellm = pythonPackages.litellm;
}
