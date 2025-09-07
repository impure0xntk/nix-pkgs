{
  pkgs,
  lib,
  ...
}:
pkgs.buildNpmPackage rec {
  pname = "mcp-server-spec-workflow";
  version = "0.0.23";

  src = pkgs.fetchFromGitHub {
    owner = "Pimzino";
    repo = "spec-workflow-mcp";
    rev = "43af4b4c872b8239f9d33d3f3b06a324a5df6032"; # main branch latest commit
    hash = "sha256-MqUHi8yQoid4id4GaUF1x70BFjEN60ZDrjG1nfHpu3E=";
  };

  npmDeps = pkgs.importNpmLock {
    npmRoot = src;
  };

  npmConfigHook = pkgs.importNpmLock.npmConfigHook;

  nativeBuildInputs = with pkgs; [
    typescript
  ];

  dontCheckForBrokenSymlinks = true;

  meta = {
    description = "A Model Context Protocol (MCP) server that provides structured spec-driven development workflow tools";
    homepage = "https://github.com/Pimzino/spec-workflow-mcp";
    license = lib.licenses.gpl3;
    mainProgram = "spec-workflow-mcp";
  };
}