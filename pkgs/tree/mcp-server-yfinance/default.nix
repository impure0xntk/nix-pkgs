{
  pkgs,
  lib,
  ...
}:
let
  pythonPkgs = pkgs.unstable.python3Packages;
  version = "0.9.1";
  src = pkgs.fetchFromGitHub {
    owner = "narumiruna";
    repo = "yfinance-mcp";
    rev = "v${version}";
    hash = "sha256-pxDEXDxfOKC64aIo6v4BS6aAUsz9AX+d6E8aNw4Odbw=";
  };
in
pythonPkgs.buildPythonApplication {
  pname = "mcp-server-yfinance-narumi";
  inherit version src;

  pyproject = true;

  build-system = with pythonPkgs; [
    hatchling
  ];

  dependencies = with pythonPkgs; [
    loguru
    mcp
    mplfinance
    tabulate
    yfinance
  ];

  # Disable tests for now - can enable once we know the test structure
  doCheck = false;

  meta = {
    description = "No description or website provided";
    homepage = "https://github.com/narumiruna/yfinance-mcp";
    license = lib.licenses.mit;
    mainProgram = "yfmcp";
  };
}
