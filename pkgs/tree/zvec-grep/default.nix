{
  pkgs,
  lib,
  ...
}:

let
  onnxruntime = pkgs.onnxruntime;
in
pkgs.buildNpmPackage rec {
  pname = "zvec-grep";
  version = "0.2.2";

  src = pkgs.fetchFromGitHub {
    owner = "zvec-ai";
    repo = "zvec-grep";
    rev = "v${version}";
    hash = "sha256-TDEK7ioPJWShJr5Ch3S6ObwgKqNnP8p9JTWYE2QZ3Z4=";
  };

  npmDeps = pkgs.importNpmLock {
    npmRoot = src;
  };

  npmConfigHook = pkgs.importNpmLock.npmConfigHook;

  nativeBuildInputs = [
  ];

  buildInputs = [
    onnxruntime
  ];

  # Prevent onnxruntime-node from downloading the CUDA runtime
  # from the GitHub release during the sandboxed npm install.
  env.ONNXRUNTIME_NODE_INSTALL_CUDA = "skip";

  postBuild = ''
    ort_node="$PWD/node_modules/onnxruntime-node"
    ort_bin="$ort_node/bin/napi-v3/linux/x64"

    if [ ! -d "$ort_bin" ]; then
      echo "error: onnxruntime-node runtime directory not found: $ort_bin"
      exit 1
    fi

    # Remove the npm-provided ONNX Runtime libraries.
    rm -f "$ort_bin"/libonnxruntime.so*

    # Replace them with the Nix-provided runtime.
    for lib in ${onnxruntime}/lib/libonnxruntime.so*; do
      ln -s "$lib" "$ort_bin/$(basename "$lib")"
    done

    echo "onnxruntime-node runtime:"
    ls -la "$ort_bin"
  '';

  meta = {
    description =
      "Local-first search across your workspace, built for humans and AI agents";
    homepage = "https://github.com/zvec-ai/zvec-grep";
    license = lib.licenses.asl20;
    platforms = lib.platforms.linux;
    mainProgram = "zg";
  };
}