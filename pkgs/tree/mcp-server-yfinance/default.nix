{
  pkgs,
  lib,
  ...
}:
pkgs.buildNpmPackage rec {
  pname = "mcp-server-yfinance";
  version = "09efa2bf58e138b23f60e8af83ab585e751eced3"; # 2025-04-06
  src = pkgs.fetchFromGitHub {
    owner = "onori";
    repo = "yfinance-mcp-server";
    rev = version;
    hash = "sha256-W8VEzC/EeSjR5bEbdkcbmdLpNIHaKo25ARWfBe0XWTc=";
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
    description = "Unofficial MCP server for Yahoo Finance stock data.";
    homepage = "https://github.com/onori/yfinance-mcp-server";
    license = lib.licenses.isc;
    mainProgram = "yfinance-mcp-server";
  };
}