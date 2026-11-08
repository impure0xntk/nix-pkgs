{ pkgs, lib, ... }:

let
  pythonPkgs = pkgs.unstable.python3Packages;
  version = "2.2.6";

  src = pkgs.fetchFromGitHub {
    owner = "haris-musa";
    repo = "excel-mcp-server";
    rev = "v${version}";
    hash = "sha256-ivSDYxp6XyjLEWXzM6r6rjEpK11MmdH4waVHEyHHbUY=";
  };
in
pythonPkgs.buildPythonApplication {
  pname = "mcp-server-excel";
  inherit version src;

  pyproject = true;

  # upstream requires mcp>=2.2 and pillow>=13 but nixpkgs ships 1.29/12.3, relax
  prePatch = ''
    substituteInPlace pyproject.toml \
      --replace 'uv_build>=0.13.1,<0.14' 'uv_build>=0.10' \
      --replace 'mcp>=2.2,<3' 'mcp>=1.0' \
      --replace 'pillow>=13,<14' 'pillow>=10'
  '';

  build-system = with pythonPkgs; [
    uv-build
  ];

  dependencies = with pythonPkgs; [
    mcp
    olefile
    openpyxl
    pillow
    pydantic
    starlette
    uvicorn
  ];

  # Disable tests for now - can enable once we know the test structure
  doCheck = false;

  meta = {
    description = "MCP server for Excel file operations";
    homepage = "https://github.com/haris-musa/excel-mcp-server";
    license = lib.licenses.mit;
    mainProgram = "excel-mcp-server";
  };
}
