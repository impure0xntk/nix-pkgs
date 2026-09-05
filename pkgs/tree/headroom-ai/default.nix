{ pkgs, lib, ... }:
let
  python = pkgs.unstable.python3;

  baseDependencies = with python.pkgs; [
    tiktoken
    pydantic
    click
    rich
    opentelemetry-api
    pyyaml
    tomlkit
    litellm
    ast-grep-cli
  ];

  optionalDeps = {
    proxy = with python.pkgs; [
      fastapi
      uvicorn
      httpx
      openai
      mcp
      magika
      zstandard
      websockets
      onnxruntime
      watchdog
      sqlite-vec
      transformers
      orjson
      trafilatura # HTML compression
      h2 # "ImportError: Using http2=True, but the 'h2'" workaround
      gunicorn # proxy-prod
    ];
    code = with python.pkgs; [
      tree-sitter
      tree-sitter-language-pack
    ];
  };

  version = "0.37.0";

  src = pkgs.fetchFromGitHub {
    owner = "headroomlabs-ai";
    repo = "headroom";
    rev = "v${version}";
    hash = "sha256-89Tkzx56QIZWfNWLaiPdMynZGOLPr5EAP5RnLSgvBsA=";
  };

  doCheck = false;
  pythonImportsCheck = [ "headroom" ];

  preFixup = ''
    wrapProgram $out/bin/headroom \
      --prefix LD_LIBRARY_PATH : "${pkgs.unstable.onnxruntime}/lib"
  '';

  meta = with lib; {
    description = "Context optimization layer for LLM applications";
    homepage = "https://github.com/headroomlabs-ai/headroom";
    license = licenses.asl20;
    mainProgram = "headroom";
    maintainers = [ ];
    platforms = platforms.linux;
  };

  mkDrv = extraNames:
    let
      selected = lib.concatLists (map (n: optionalDeps.${n} or []) extraNames);
    in
    python.pkgs.buildPythonPackage rec {
      inherit version;
      format = "pyproject";
      inherit src doCheck pythonImportsCheck preFixup meta;

      pname = if extraNames == [ ] then "headroom-ai"
              else "headroom-ai-${lib.concatStringsSep "-" extraNames}";

      nativeBuildInputs = with pkgs.unstable.rustPlatform; [
        maturinBuildHook
        cargoSetupHook
      ];

      dependencies = baseDependencies ++ selected;

      cargoDeps = pkgs.unstable.rustPlatform.fetchCargoVendor {
        inherit pname version src;
        hash = "sha256-iEvap6uLsAqCSv+l/S7K7osxL+yV7Y8pE6Dhaqt2AIA=";
      };
    };
in
mkDrv [ ] // {
  proxy = mkDrv [ "proxy" ];
  code-proxy = mkDrv [ "code" "proxy" ];
}
