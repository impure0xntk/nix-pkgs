# From https://github.com/NixOS/nixpkgs/issues/148048
{ pkgs, ... }:
pkgs.stdenv.mkDerivation rec {
  pname   = "infer";
  version = "1.2.0";

  src = pkgs.fetchzip {
    url = "https://github.com/facebook/infer/releases/download/v${version}/infer-linux-x86_64-v${version}.tar.xz";
    hash = "sha256-KcUVowgamAcE9Fg2QmtUtifULt3ILaiDUZxLG/L2HQs=";
  };

  buildInputs = with pkgs; [
    ncurses
    libxml2
    zlib
    # From 1.2.0
    zstd
  ];
  nativeBuildInputs = [ pkgs.autoPatchelfHook ];

  installPhase = ''
    # This depends libclang and libpython: there are huge.
    # But this is unnecessary for java.
    rm -r ./lib/infer/facebook-clang-plugins

    mkdir -p $out/{bin,lib}

    cp -r ./bin $out
    cp -r ./lib $out
  '';
}

