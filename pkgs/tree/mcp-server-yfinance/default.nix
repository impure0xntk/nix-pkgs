{
  pkgs,
  lib,
  ...
}:
let
  pythonPkgs = pkgs.unstable.python3Packages;
  version = "0.14.0";
  src = pkgs.fetchFromGitHub {
    owner = "narumiruna";
    repo = "yfinance-mcp";
    rev = "v${version}";
    hash = "sha256-egR1koZgCnE5pOKrZEgiMg6CJwmkLQz/OXnkLeVE4Yg=";
  };
in
pythonPkgs.buildPythonApplication {
  pname = "mcp-server-yfinance-narumi";
  inherit version src;

  pyproject = true;

  nativeBuildInputs = with pythonPkgs; [
    pythonRelaxDepsHook
  ];

  build-system = with pythonPkgs; [
    hatchling
  ];

  dependencies = with pythonPkgs; [
    loguru
    matplotlib
    mcp
    tabulate
    yfinance
  ];

  pythonRelaxDeps = [
    "yfinance"
    "tabulate"
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
