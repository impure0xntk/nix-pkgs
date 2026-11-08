{ pkgs, lib, ... }:

let
  version = "0.3.0";
  src = pkgs.fetchFromGitHub {
    owner = "zvec-ai";
    repo = "zvec-grep";
    rev = "v${version}";
    hash = "sha256-m+EshRJznj27l4wFh8CxKJVH5eaIJKUEZylDEKd0BuU=";
  };
  zvecPrebuilt = pkgs.fetchurl {
    url = "https://github.com/zvec-ai/zvec-rust/releases/download/v0.8.0/zvec-prebuilt-x86_64-unknown-linux-gnu.tar.gz";
    hash = "sha256-Vlj5xuhrWlEcKmEU8UoUdeWuVMakvx2OD72jRIzZYBM=";
  };
  llamaSrc = pkgs.fetchurl {
    url = "https://codeload.github.com/ggml-org/llama.cpp/tar.gz/5f55650a78f92aff4d48d671423e888fac0469ff";
    hash = "sha256-++BXvv3UkEatu82fGa004EyYFVh0TVXbGHAvQdTQGwc=";
  };
in
pkgs.unstable.rustPlatform.buildRustPackage {
  pname = "zvec-grep";
  inherit version src;
  sourceRoot = "source/rust";
  cargoBuildFlags = [ "-p" "zg" ];
  cargoHash = "sha256-74C/wZ0n49Li+KykvVLklj/yCxPkwb8YNBrfnUKw54k=";
  doCheck = false;

  nativeBuildInputs = with pkgs.unstable; [
    python3
    curl
    wget
    git
    cmake
    pkg-config
    gnutar
    gzip
    clang
    libclang
  ];

  preBuild = ''
    mkdir -p $TMPDIR/zvec-lib
    tar -xzf ${zvecPrebuilt} -C $TMPDIR/zvec-lib
    export ZVEC_LIB_DIR=$TMPDIR/zvec-lib
    export ORT_DYLIB_PATH=${pkgs.onnxruntime}/lib/libonnxruntime.so.1.21.0
    if [ ! -f $ORT_DYLIB_PATH ]; then
      ORT_DYLIB_PATH=$(ls ${pkgs.onnxruntime}/lib/libonnxruntime.so.* | head -n1)
    fi
    export ORT_DYLIB_PATH
    # llama.cpp pinned source
    mkdir -p $TMPDIR/llama-src
    tar -xzf ${llamaSrc} -C $TMPDIR/llama-src --strip-components=1
    export LLAMA_CPP_SOURCE_DIR=$TMPDIR/llama-src
    export LIBCLANG_PATH=${pkgs.unstable.libclang.lib}/lib
    echo "ZVEC_LIB_DIR=$ZVEC_LIB_DIR ORT_DYLIB_PATH=$ORT_DYLIB_PATH LLAMA_CPP_SOURCE_DIR=$LLAMA_CPP_SOURCE_DIR LIBCLANG_PATH=$LIBCLANG_PATH"
    ls -la $ZVEC_LIB_DIR
    ls $LLAMA_CPP_SOURCE_DIR/CMakeLists.txt
  '';

  meta = {
    description = "Local-first hybrid search across workspace, built for humans and AI agents";
    homepage = "https://github.com/zvec-ai/zvec-grep";
    license = lib.licenses.asl20;
    mainProgram = "zg";
    platforms = lib.platforms.linux;
  };
}
