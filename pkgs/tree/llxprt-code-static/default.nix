{ pkgs,
  nodejs,
  ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "llxprt-code-static";
  version = "0.1.12";
  src = pkgs.fetchurl { # single js
    url = "https://github.com/acoliver/llxprt-code/releases/download/v${version}/llxprt.js";
    hash = "sha256-WyOMZLzRJCdot2WxzIIiVxKpXKdyXqN29NOXoDyC0J0=";
  };
  nativeBuildInputs = [ pkgs.makeWrapper ];
  phases = [ "installPhase" ];
  installPhase = ''
    mkdir -p $out/{bin,share}
    cp $src $out/share/llxprt.js

    makeWrapper "${nodejs}/bin/node" $out/bin/llxprt \
      --add-flags "$out/share/llxprt.js"
  '';
  meta = with pkgs.lib; {
    homepage = "https://github.com/acoliver/llxprt-code";
    description = "An open-source multi-provider (including local) fork of gemini-cli. Use whatever LLM you want to code in your terminal.";
    license = with licenses; [asl20];
  };
}
