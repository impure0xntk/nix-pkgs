{
  pkgs,
  lib,
  ...
}:
pkgs.buildNpmPackage rec {
  pname = "mcp-server-quickchart";
  version = "1.0.6"; # no tags, from commit message.
  src = pkgs.fetchFromGitHub {
    owner = "GongRzhe";
    repo = "Quickchart-MCP-Server";
    rev = "aba9fd76df247fd545e05f295274cb9e4ae456e8";
    hash = "sha256-g3s1ZYzMcZ5JfKCeUAO/qpucT8fGplwMwOew+P+8tq4=";
  };

  npmDeps = pkgs.importNpmLock {
    npmRoot = src;
  };

  npmConfigHook = pkgs.importNpmLock.npmConfigHook;

  nativeBuildInputs = with pkgs; [
    typescript
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r node_modules $out/
    cp -r build $out/
    echo '#!${pkgs.bash}/bin/bash' > $out/bin/mcp-server-quickchart
    echo "export NODE_PATH=$out/node_modules; ${pkgs.nodejs}/bin/node $out/build/index.js \"\$@\"" >> $out/bin/mcp-server-quickchart
    chmod +x $out/bin/mcp-server-quickchart
    
    runHook postInstall
  '';

  dontCheckForBrokenSymlinks = true;

  meta = {
    description = "A visualization Model Context Protocol server for generating 25+ visual charts using @antvis.";
    homepage = "https://github.com/antvis/mcp-server-chart";
    license = lib.licenses.mit;
    mainProgram = "mcp-server-quickchart";
  };
}