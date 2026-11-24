{
  pkgs,
  lib,
  ...
}:
let
  # To pin mcp
  pythonRev = pkgs.multiverse.revOf "python3" "3.14.7";
  pythonPkgs = (pkgs.multiverse.at pythonRev).python3Packages;

  version = "0.14.1";
  src = pkgs.fetchFromGitHub {
    owner = "narumiruna";
    repo = "yfinance-mcp";
    rev = "v${version}";
    hash = "sha256-eoKdZCx5kauWHuCQLNZmxJc6MSwyx8F0GjS0GiBEU6w=";
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

  # 0.14.1 raises mcp>=1.30.0,<2 / loguru>=0.8.0 / matplotlib>=3.11.2, none of
  # which the pinned multiverse rev can satisfy; relax and use what is pinned.
  pythonRelaxDeps = [
    "yfinance"
    "tabulate"
    "loguru"
    "matplotlib"
    "mcp"
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
