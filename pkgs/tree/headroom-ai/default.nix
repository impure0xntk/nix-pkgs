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
    truststore
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

  version = "0.43.1";

  src = pkgs.fetchFromGitHub {
    owner = "headroomlabs-ai";
    repo = "headroom";
    rev = "v${version}";
    hash = "sha256-lZNB0v5nheQyiZF4EoRgqqsjmGjg7n98OgiWQCZejXQ=";
  };

  doCheck = false;
  pythonImportsCheck = [ "headroom" ];

  preFixup = ''
    ortLib="$(${pkgs.findutils}/bin/find \
      "${python.pkgs.onnxruntime}/${python.sitePackages}/onnxruntime/capi" \
      -maxdepth 1 \
      -name 'libonnxruntime.so.*' \
      -type f \
      -print -quit)"

    if [ -z "$ortLib" ]; then
      echo "error: libonnxruntime.so.* not found" >&2
      exit 1
    fi

    echo "Using ONNX Runtime: $ortLib"

    wrapProgram $out/bin/headroom \
      --set ORT_DYLIB_PATH "$ortLib" \
      --prefix LD_LIBRARY_PATH : "${pkgs.unstable.stdenv.cc.cc.lib}/lib"
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
        hash = "sha256-NkbMkyCc2i64nhKBE7ZdSAjefvhQac+InWDjlbQg474=";
      };

      # nixpkgs-unstable pins are behind upstream floors; relax
      prePatch = ''
        substituteInPlace pyproject.toml \
          --replace 'opentelemetry-api>=1.45.1' 'opentelemetry-api>=1.0' \
          --replace 'tomlkit>=0.15.2,<1.0' 'tomlkit>=0.15' \
          --replace 'filelock>=4.2.1' 'filelock>=3.0' \
          --replace 'click>=8.3.3' 'click>=8.0'
      '';
    };
in
mkDrv [ ] // {
  proxy = mkDrv [ "proxy" ];
  code-proxy = mkDrv [ "code" "proxy" ];
}
