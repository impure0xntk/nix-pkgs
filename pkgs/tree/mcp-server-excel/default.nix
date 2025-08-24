# https://github.com/timblaktu/mcp-servers-nix/blob/6bd16cd70225afeb6278b2489b79d2f356b9acd2/pkgs/official/mcp-nixos/default.nix
{
  pkgs,
  lib,
  ...
}:
let
  typer' = pkgs.python3Packages.typer.overridePythonAttrs (old: rec {
    version = "0.16.1";
    src = pkgs.fetchFromGitHub {
      owner = "fastapi";
      repo = "typer";
      tag = version;
      hash = "sha256-6a2y0WlD0CK9a1zSvHCZPP0anhRBJ5+FGrQcNfxlg1U=";
    };
  });
in
pkgs.python3Packages.buildPythonApplication rec {
  pname = "mcp-server-excel";
  version = "0.1.7";

  src = pkgs.fetchFromGitHub {
    owner = "haris-musa";
    repo = "excel-mcp-server";
    rev = "v${version}";
    hash = "sha256-pXMC+yLFFjhYlDy7zm9SdFzPTubmxvNXIqtPuBmtdJc=";
  };

  pyproject = true;

  patches = [
    ./patch-excel-mcp-log
  ];

  build-system = with pkgs.python3Packages; [
    hatchling
  ];

  dependencies = with pkgs.python3Packages; [
    fastmcp
    openpyxl
    typer'
  ];

  # Disable tests for now - can enable once we know the test structure
  doCheck = false;

  meta = {
    description = "A Model Context Protocol server for Excel file manipulation";
    homepage = "https://github.com/haris-musa/excel-mcp-server";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ]; # Add maintainer here
    mainProgram = "excel-mcp-server";
  };
}
