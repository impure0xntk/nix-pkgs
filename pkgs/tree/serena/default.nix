{
  pkgs,
  lib,
  ...
}:
let
  anthropic = pkgs.python3Packages.anthropic.overridePythonAttrs (old: rec {
    version = "0.54.0";
    src = pkgs.fetchFromGitHub {
      owner = "anthropics";
      repo = "anthropic-sdk-python";
      tag = "v${version}";
      hash = "sha256-ajxePJZ+UsVDVd825ZzgvZ1Wgl/Dj2Eh58OSAhbiV9I=";
    };
  });
  joblib = pkgs.python3Packages.joblib.overridePythonAttrs (old: rec {
    version = "1.5.1";
    src = pkgs.fetchPypi {
      pname = old.pname;
      inherit version;
      hash = "sha256-9PhuNR85/j0NMqnyw9ivHuTOwoWq/LJwA92lIFV2tEQ=";
    };
  });
  sensai-utils = pkgs.python3Packages.sensai-utils.overridePythonAttrs (old: rec {
    version = "1.5.0";
    src = pkgs.fetchFromGitHub {
      owner = "opcode81";
      repo = "sensAI-utils";
      tag = "v${version}";
      hash = "sha256-bAbgamJjB+NpPnZHqYOrOhatGGgjzy558BrF3GwHOHE=";
    };
  });
  pyright = pkgs.python3Packages.buildPythonApplication rec {
    pname = "pyright-python";
    version = "1.1.404";

    src = pkgs.fetchFromGitHub {
      owner = "RobertCraigie";
      repo = pname;
      rev = "v${version}";
      hash = "sha256-QIidogVcU+NqpOU5s9Y74aNXz6G4z0qPUdTQ9fd36VM=";
    };

    pyproject = true;

    build-system = with pkgs.python3Packages; [
      setuptools
    ];

    dependencies = with pkgs.python3Packages; [
      nodeenv
      typing-extensions
    ];

    # Disable tests for now - can enable once we know the test structure
    doCheck = false;

    meta = {
      description = "Python command line wrapper for pyright, a static type checker";
      homepage = "https://github.com/RobertCraigie/pyright-python";
      license = lib.licenses.mit;
    };
  };
in
pkgs.python3Packages.buildPythonApplication rec {
  pname = "serena";
  version = "0.1.4";

  src = pkgs.fetchFromGitHub {
    owner = "oraios";
    repo = "serena";
    rev = "v${version}";
    hash = "sha256-oj5iaQZa9gKjjaqq/DDT0j5UqVbPjWEztSuaOH24chI=";
  };

  pyproject = true;

  build-system = with pkgs.python3Packages; [
    hatchling
  ];

  dependencies = [
    anthropic
    joblib
    sensai-utils
    pyright
  ] ++ (with pkgs.python3Packages; [
    mcp
    requests
    overrides
    python-dotenv

    flask
    pydantic
    types-pyyaml
    pyyaml
    ruamel-yaml
    jinja2
    pathspec
    psutil
    docstring-parser
    joblib
    tqdm
    tiktoken
  ]);

  # dotenv is deprecated.
  # original allows mcp 1.12.3, too strict.
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"dotenv>=0.9.9",' \
        '"python-dotenv>=1.1.0",' \
      --replace-fail '"mcp==1.12.3",' \
        '"mcp>=1.12.3",'
  '';

  # Disable tests for now - can enable once we know the test structure
  doCheck = false;

  meta = {
    description = "A powerful coding agent toolkit providing semantic retrieval and editing capabilities (MCP server & Agno integration)";
    homepage = "https://github.com/oraios/serena";
    license = lib.licenses.mit;
    mainProgram = "serena";
  };
}
