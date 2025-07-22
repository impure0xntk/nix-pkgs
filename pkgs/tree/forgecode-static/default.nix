{ pkgs,
  ... }:
pkgs.stdenv.mkDerivation rec {
  pname = "forge";
  version = "0.100.7";

  src = pkgs.fetchurl {
    url = "https://github.com/antinomyhq/forge/releases/download/v${version}/forge-x86_64-unknown-linux-musl";
    hash = "sha256-GlUiMTROApa1XUBV9OxrtPGyGYmb8Ng90gOKfpTACN4=";
  };

  dontUnpack = true;
  nativeBuildInputs = [ pkgs.autoPatchelfHook ];
  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/forge
    chmod +x $out/bin/forge
  '';

  meta = with pkgs.lib; {
    homepage = "https://github.com/antinomyhq/forge";
    description = "AI enabled pair programmer for Claude, GPT, O Series, Grok, Deepseek, Gemini and 300+ models";
    license = with licenses; [asl20];
    platforms = platforms.linux;
  };
}

