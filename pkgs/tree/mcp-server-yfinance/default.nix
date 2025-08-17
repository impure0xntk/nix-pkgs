{
  pkgs,
  lib,
  ...
}:
let
in
pkgs.python3Packages.buildPythonApplication rec {
  pname = "mcp-server-yfinance-narumi";
  version = "0.4.5";

  src = pkgs.fetchFromGitHub {
    owner = "narumiruna";
    repo = "yfinance-mcp";
    rev = "v${version}";
    hash = "sha256-iIA8NsMkH0s48v0B5EcxtAx8o5po0y/PNQPGcGF6un8=";
  };

  pyproject = true;

  build-system = with pkgs.python3Packages; [
    hatchling
  ];

  dependencies = with pkgs.python3Packages; [
    loguru
    mcp
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
