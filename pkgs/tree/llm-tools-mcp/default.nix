# Expects mcp > 1.6.0. See overlays/python-packages/mcp
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
      owner = "VirtusLab";
      repo = "llm-tools-mcp";
      tag = "0.3";
      hash = "sha256-Hf8gIdKYHsEN9XeWTwwCQux2ZrpKvdONRTI3VcrQ+5w=";
    };
  };
  attrs = project.renderers.buildPythonPackage { inherit python; };
in 
pkgs.python3Packages.buildPythonPackage attrs
