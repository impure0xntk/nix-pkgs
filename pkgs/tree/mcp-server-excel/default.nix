{ pkgs, lib, ... }:

let
  pythonPkgs = pkgs.python3Packages;
  version = "0.1.8";

  src = pkgs.fetchFromGitHub {
    owner = "haris-musa";
    repo = "excel-mcp-server";
    rev = "v${version}";
    hash = "sha256-F3QIAZWbuyE2Yl3e88HD9CZvkBpeMJI/Lm6uXuUgWKg=";
  };
in
pythonPkgs.buildPythonApplication {
  pname = "mcp-server-excel";
  inherit version src;

  pyproject = true;

  build-system = with pythonPkgs; [
    hatchling
  ];

  dependencies = with pythonPkgs; [
    loguru
    mcp
    fastmcp
    openpyxl
    pandas
    python-dotenv
    typer
  ];

  # Patch pyproject.toml to accept fastmcp 3.x
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace 'fastmcp>=2.0.0,<3.0.0' 'fastmcp>=2.0.0'
  '';

  # Disable tests for now - can enable once we know the test structure
  doCheck = false;

  meta = {
    description = "MCP server for Excel file operations";
    homepage = "https://github.com/haris-musa/excel-mcp-server";
    license = lib.licenses.mit;
    mainProgram = "excel-mcp-server";
  };
}
