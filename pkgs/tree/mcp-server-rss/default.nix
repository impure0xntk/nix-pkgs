# This derivation is not used directly.
# However, it is kept in the repository
# because it is useful for editing package-lock.json.
{
  pkgs,
  lib,
  ...
}:
pkgs.buildNpmPackage rec {
  pname = "mcp-rss-aggregator";
  version = "0.3.0";
  src = pkgs.fetchFromGitHub {
    owner = "imprvhub";
    repo = pname;
    rev = "0.3.0";
    hash = "sha256-Rf/i4wmidspgVyRY+QOSIr75TEs9GAk0OIDdIeFshds=";
  };

  npmDeps = pkgs.importNpmLock {
    npmRoot = src;
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
    cp -r build $out/
    echo '#!${pkgs.bash}/bin/bash' > $out/bin/mcp-rss-aggregator
    echo "export NODE_PATH=$out/node_modules; ${pkgs.nodejs}/bin/node $out/build/index.js \"\$@\"" >> $out/bin/mcp-rss-aggregator
    chmod +x $out/bin/mcp-rss-aggregator

    runHook postInstall
  '';

  dontCheckForBrokenSymlinks = true;

  meta = {
    description = "Model Context Protocol Server for aggregating RSS feeds in Claude Desktop";
    homepage = "https://github.com/imprvhub/mcp-rss-aggregator";
    license = lib.licenses.mpl20;
    mainProgram = "mcp-rss-aggregator";
  };
}
