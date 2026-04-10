{
  pkgs,
  lib,
  ...
}:
pkgs.stdenv.mkDerivation (finalAttrs: rec {
  pname = "NanoProxy";
  version = "1a67f28fb2aaf015e3fba234dd36ced43353a999";
  src = pkgs.fetchFromGitHub {
    owner = "nanogpt-community";
    repo = pname;
    rev = version;
    hash = "sha256-G67GwGIkUSvO9XtPwAVrY7s3N4FwLYyIRJ2YPvUMvME=";
  };

  nativeBuildInputs = with pkgs; [
    nodejs
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r src $out/
    cp -r server.js $out/
    echo '#!${pkgs.bash}/bin/bash' > $out/bin/nanoproxy
    echo "export NODE_PATH=$out/src; ${pkgs.nodejs}/bin/node $out/server.js \"\$@\"" >> $out/bin/nanoproxy
    chmod +x $out/bin/nanoproxy

    runHook postInstall
  '';

  meta = {
    description = "A local proxy for OpenCode and similar OpenAI-compatible coding clients that works around NanoGPT’s often unreliable native tool calling. Instead of relying on NanoGPT to return proper tool calls directly, it sends a stricter text-based tool format upstream and converts that back into normal OpenAI-style tool calls for the client.";
    homepage = "https://github.com/nanogpt-community/NanoProxy";
    license = lib.licenses.mit;
    mainProgram = "nanoproxy";
  };
})