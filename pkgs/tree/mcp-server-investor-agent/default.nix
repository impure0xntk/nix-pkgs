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

  pnpmDeps = pkgs.fetchPnpmDeps {
    inherit pname version src;
    fetcherVersion = 3;
    hash = "sha256-cG1NsbHyezqn6yEL8p5/w/4Sbtfo19/5W/ziEANbOKo=";
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
