{ pkgs, lib, ... }:
let
  python = pkgs.pure-unstable;
in
python.python3Packages.buildPythonPackage rec {
  pname = "headroom-ai";
  version = "0.5.20";
  pyproject = true;

  src = python.fetchPypi {
    pname = "headroom_ai";
    inherit version;
    hash = "sha256-vJf8eSjeGynxDlwWNOJvDrnhAJQjT9nPrNXPPJMQ7Wg=";
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

    # code
    tree-sitter-language-pack
  ];

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