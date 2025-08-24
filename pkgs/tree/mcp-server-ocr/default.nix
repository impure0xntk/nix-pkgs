{
  pkgs,
  lib,
  ...
}:
let
in
pkgs.python3Packages.buildPythonApplication rec {
  pname = "mcp-server-ocr";
  version = "0.1.2";

  src = pkgs.fetchFromGitHub {
    owner = "rjn32s";
    repo = "mcp-ocr";
    rev = "v${version}";
    hash = "sha256-/yhBBVEnjAvbhytW5fmy6//XnJ4mlH62wt1Be84Mfl0=";
  };

  pyproject = true;

  build-system = with pkgs.python3Packages; [
    hatchling
  ];

  dependencies = with pkgs.python3Packages; [
    mcp
    pytesseract
    opencv-python
    numpy
    pillow
    httpx
  ];

  # Disable tests for now - can enable once we know the test structure
  doCheck = false;

  meta = {
    description = "No description or website provided";
    homepage = "https://github.com/rjn32s/mcp-ocr";
    license = lib.licenses.mit;
    mainProgram = "mcp-ocr";
  };
}
