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
    rev = "7ab5a9ab0522e9427077024c4be42b8f076398e3"; # 2026-09-02
    hash = "sha256-h8qSF8qHDssrZafQFY7WbOhOww54sa5eswyHaz91RdI=";
  };

  pnpmDeps = pkgs.fetchPnpmDeps {
    inherit pname version src;
    fetcherVersion = 4;
    hash = "sha256-YNCtrikHE/q00oXicB9ZIlP1ZsRNv1/gJKsFpfZOU3Y=";
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
