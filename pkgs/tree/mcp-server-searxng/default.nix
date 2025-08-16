{
  pkgs,
  lib,
  ...
}:
pkgs.buildNpmPackage rec {
  pname = "mcp-server-searxng";
  version = "0.3.9";
  src = pkgs.fetchFromGitHub {
    owner = "kevinwatt";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-TZi7UQOLwLHPzyfxsnvvJj/XqoeiXqfUwjDQi9jgvB8=";
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
    description = "An MCP server implementation that integrates with SearXNG, providing privacy-focused meta search capabilities.";
    homepage = "https://github.com/kevinwatt/mcp-server-searxng";
    license = lib.licenses.mit;
    mainProgram = "mcp-server-searxng";
  };
}