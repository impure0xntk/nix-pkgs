# Expects mcp > 1.6.0. See overlays/python-packages/mcp

# Not used, just keep for pyproject-nix examples.
{
  pkgs,
  lib,
  pyproject-nix,
  ...
}:
let 
  python = pkgs.python3;
  project = pyproject-nix.lib.project.loadPyproject {
    projectRoot = pkgs.fetchFromGitHub {
      owner = "simonw";
      repo = "llm-openrouter";
      tag = "0.4.1";
      hash = "sha256-ojBkyXqEaqTcOv7mzTWL5Ihhb50zeVzeQZNA6DySuVg=";
    };
  };
  attrs = project.renderers.buildPythonPackage { inherit python; };
in 
pkgs.python3Packages.buildPythonPackage attrs
