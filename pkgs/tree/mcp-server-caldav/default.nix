{
  pkgs,
  lib,
  ...
}:
pkgs.buildNpmPackage rec {
  pname = "mcp-server-caldav";
  version = "0.5.0";
  src = pkgs.fetchFromGitHub {
    owner = "dominik1001";
    repo = "caldav-mcp";
    rev = "v${version}";
    hash = "sha256-7xnJFblZKOgMYTG+usqVkNSantF/O11/6R2dIGUgLyk=";
  };

  npmDeps = pkgs.importNpmLock {
    package = lib.importJSON "${src}/package.json";
    packageLock = lib.importJSON "${src}/package-lock.json";
  };

  npmConfigHook = pkgs.importNpmLock.npmConfigHook;

  nativeBuildInputs = with pkgs; [
    nodejs
    typescript
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r node_modules $out/
    cp -r dist $out/
    echo '#!${pkgs.bash}/bin/bash' > $out/bin/mcp-server-caldav
    echo "export NODE_PATH=$out/node_modules; ${pkgs.nodejs}/bin/node $out/dist/index.js \"\$@\"" >> $out/bin/mcp-server-caldav
    chmod +x $out/bin/mcp-server-caldav

    runHook postInstall
  '';

  meta = {
    description = "🗓️ A CalDAV Model Context Protocol (MCP) server to expose calendar operations as tools for AI assistants.";
    homepage = "https://github.com/dominik1001/caldav-mcp";
    license = lib.licenses.mit;
    mainProgram = "mcp-server-caldav";
  };
}
