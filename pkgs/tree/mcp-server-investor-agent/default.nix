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
    rev = "2a71d057da2a03f5bf971331d76dad32bd4c5ab5"; # 2026-05-04
    hash = "sha256-1GhKWI/3CLw3U7NLM+jRdJNGtmPqTYhCNzInmiCYBQQ=";
  };

  pnpmDeps = pkgs.pnpm.fetchDeps {
    inherit pname version src;
    fetcherVersion = 1;
    hash = "sha256-AQtTarIvzB1t7L0eingDJE+vfY5H3/lrFj4DGk0lvms=";
  };

  nativeBuildInputs = [
    pkgs.nodejs
    pkgs.pnpm.configHook
    pkgs.typescript
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