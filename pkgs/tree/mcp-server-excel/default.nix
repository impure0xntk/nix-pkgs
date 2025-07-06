# https://github.com/timblaktu/mcp-servers-nix/blob/6bd16cd70225afeb6278b2489b79d2f356b9acd2/pkgs/official/mcp-nixos/default.nix
{
  pkgs,
  lib,
  ...
}:
let
in
pkgs.python3Packages.buildPythonApplication rec {
  pname = "mcp-server-excel";
  version = "0.1.4";

  src = pkgs.fetchFromGitHub {
    owner = "haris-musa";
    repo = "excel-mcp-server";
    rev = "v${version}";
    hash = "sha256-D7++tjn9W+WYjeSSVoVpvuvQWOvoISqPbzvtQpTPELg=";
  };

  pyproject = true;

  build-system = with pkgs.python3Packages; [
    hatchling
  ];

  dependencies = with pkgs.python3Packages; [
    mcp
    openpyxl
    typer
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
