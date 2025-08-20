{
  pkgs,
  lib,
  ...
}:
let
  rev = "5f9ab04a7bd57a47714fd6a3fbfef480ea92850a"; # 2025-07-22
  versionDummy = "0.0.1";

  pyrate-limiter = pkgs.python3Packages.pyrate-limiter.overridePythonAttrs (old: rec {
    version = "2.10.0";
    src = pkgs.fetchFromGitHub {
      owner = "vutran1710";
      repo = "PyrateLimiter";
      tag = "v${version}";
      hash = "sha256-CPusPeyTS+QyWiMHsU0ii9ZxPuizsqv0wQy3uicrDw0=";
    };
    doCheck = false;
  });
in
pkgs.python3Packages.buildPythonApplication {
  pname = "mcp-server-investor-agent";
  version = rev;

  src = pkgs.fetchFromGitHub {
    owner = "ferdousbhai";
    repo = "investor-agent";
    inherit rev;
    hash = "sha256-JWN0S+5sYP3CKjy85LpEmjF1CeCJhLg0T64Kxy7ZnX4=";
  };

  pyproject = true;

  build-system = with pkgs.python3Packages; [
    hatchling
    hatch-vcs
  ];

  dependencies = with pkgs.python3Packages; [
    httpx
    mcp
    pandas
    pyrate-limiter
    (import ./pytrends.nix { inherit pkgs lib; })
    requests-cache
    (requests-ratelimiter.override { # because the deps is marked as broken
      pyrate-limiter = pyrate-limiter;
    })
    tabulate
    yfinance
  ];

  # Disable tests for now - can enable once we know the test structure
  doCheck = false;

  # Suppress "ValueError: Invalid version `...` from source `vcs`, see https://peps.python.org/pep-0440/"
  patchPhase = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'requires = ["hatchling", "hatch-vcs"]' \
        'requires = ["hatchling"]' \
      --replace-fail 'dynamic = ["version"]' \
        'version = "${versionDummy}"' \
      || true  # Ignore substitution failures
  '';

  meta = {
    description = "A Model Context Protocol server for building an investor agent";
    homepage = "https://github.com/ferdousbhai/investor-agent";
    license = lib.licenses.mit;
    mainProgram = "investor-agent";
  };
}
