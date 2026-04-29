{ pkgs, lib, ... }:
let
  python = pkgs.pure-unstable;
in
python.python3Packages.buildPythonPackage rec {
  pname = "headroom-ai";
  version = "0.14.1";
  pyproject = true;

  src = python.fetchPypi {
    pname = "headroom_ai";
    inherit version;
    hash = "sha256-UL2ATzDr2WuRUALgqzaGIrkV9xxBI2OYSHkzd3kmaLw=";
  };

  nativeBuildInputs = with python.python3Packages; [
    hatchling
  ];

  propagatedBuildInputs = with python.python3Packages; [
    tiktoken
    pydantic
    litellm
    click
    rich
    opentelemetry-api
    # ast-grep-cli -> ast-grep binary
    tomli

    # proxy
    fastapi
    uvicorn
    httpx
    h2 # for http2 by httpx
    openai
    mcp
    magika
    zstandard
    websockets
    onnxruntime
    transformers
    watchdog

    # code
    tree-sitter-language-pack
  ] ++ [
    pkgs.pure-unstable.ast-grep # instead of ast-grep-cli
  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"ast-grep-cli>=0.30.0",' "" \
      --replace-fail '"litellm==1.82.3",' '"litellm>=1.82.3",'
  '';

  doCheck = false;

  meta = with python.lib; {
    description = "Context optimization layer for LLM applications";
    homepage = "https://github.com/chopratejas/headroom";
    license = licenses.asl20;
    mainProgram = "headroom";
    maintainers = [ ];
    platforms = platforms.linux;
  };
}