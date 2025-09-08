{
  pkgs,
  lib,
  ...
}:
pkgs.buildNpmPackage rec {
  pname = "mcp-server-dependency";
  version = "0.0.4";
  src = pkgs.fetchFromGitHub {
    owner = "niradler";
    repo = "dependency-mcp";
    rev = "57586bf00748f0a504a567988592874140388469";
    hash = "sha256-I1DqnQzZdwIkil46ODD8SohmWkv0YEW0bRXoww1WN94=";
  };

  npmDeps = pkgs.importNpmLock {
    npmRoot = src;
  };

  npmConfigHook = pkgs.importNpmLock.npmConfigHook;

  dontNpmBuild = true;

  meta = {
    description = "MCP server for checking package versions across multiple package managers";
    homepage = "https://github.com/niradler/dependency-mcp";
    license = lib.licenses.mit;
    mainProgram = "dependency-mcp";
  };
}