{
  pkgs,
  lib,
  ...
}:
pkgs.stdenv.mkDerivation rec {
  pname = "mcp-server-investor-agent";
  version = "3.0.0";

  src = pkgs.fetchFromGitHub {
    owner = "ferdousbhai";
    repo = "investor-agent";
    rev = "53286e701e442eb623f5acd6eaa451d8b1f3396d"; # 2026-08-16
    hash = "sha256-PcVIQ2Mm822+DMBT6Y3o8E8gvy/YddeL4cG0MYDPOGc=";
  };

  pnpmDeps = pkgs.fetchPnpmDeps {
    inherit pname version src;
    fetcherVersion = 3;
    hash = "sha256-Aoscc36I8f9JdkuwBfkfHkOTo1V01Ybx3mgos55kQPM=";
  };

  nativeBuildInputs = with pkgs; [
    nodejs
    pnpm
    pnpmConfigHook
    typescript
  ];

  buildPhase = ''
    runHook preBuild

    pnpm -C . exec tsc -p . --noEmit
    pnpm -C . build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r node_modules $out/
    cp -r dist $out/
    echo '#!${pkgs.bash}/bin/bash' > $out/bin/investor-agent
    echo "export NODE_PATH=$out/node_modules; ${pkgs.nodejs}/bin/node $out/dist/index.js \"\$@\"" >> $out/bin/investor-agent
    chmod +x $out/bin/investor-agent

    runHook postInstall
  '';

  meta = {
    description = "A Model Context Protocol server for building an investor agent";
    homepage = "https://github.com/ferdousbhai/investor-agent";
    license = lib.licenses.mit;
    mainProgram = "investor-agent";
  };
}
