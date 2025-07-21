{ pkgs,
  nodejs,
  ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "gemini-cli-static";
  version = "0.1.11";
  src = pkgs.fetchurl { # single js
    url = "https://github.com/google-gemini/gemini-cli/releases/download/v${version}/gemini.js";
    hash = "sha256-/YljzcHcnoieenhuGVgr8X3JbEUCHtjhIRvgP9aJ79M=";
  };
  nativeBuildInputs = [ pkgs.makeWrapper ];
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/{bin,share}
    cp $src $out/share/gemini.js

    makeWrapper "${nodejs}/bin/node" $out/bin/gemini \
      --add-flags "$out/share/gemini.js"
  '';
  meta = with pkgs.lib; {
    homepage = "https://github.com/google-gemini/gemini-cli";
    description = "An open-source AI agent that brings the power of Gemini directly into your terminal.";
    license = with licenses; [asl20];
  };
}
