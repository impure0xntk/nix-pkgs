# This derivation is not used directly.
# However, it is kept in the repository
# because it is useful for editing package-lock.json.
{
  pkgs,
  lib,
  ...
}:

pkgs.buildNpmPackage rec {
  pname = "wsl-chrome-bridge";
  version = "0.3.1";

  src = pkgs.fetchFromGitHub {
    owner = "pigochu";
    repo = "wsl-chrome-bridge";
    rev = version;
    hash = "sha256-IZh5V63Ik3yhQcHYJ+7KkITjp5Q1dD2Na9M3SqjmyLM=";
  };

  npmDeps = pkgs.importNpmLock {
    npmRoot = src;
  };
  npmConfigHook = pkgs.importNpmLock.npmConfigHook;

  nativeBuildInputs = with pkgs; [
    nodejs
    typescript
  ];

  npmBuildScript = "build";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r node_modules $out/
    cp -r dist $out/
    echo '#!${pkgs.bash}/bin/bash' > $out/bin/wsl-chrome-bridge
    echo "export NODE_PATH=$out/node_modules; ${pkgs.nodejs}/bin/node $out/dist/main.js \"\$@\"" >> $out/bin/wsl-chrome-bridge
    chmod +x $out/bin/wsl-chrome-bridge

    runHook postInstall
  '';

  dontCheckForBrokenSymlinks = true;

  meta = {
    description = "Bridge chrome-devtools-mcp/playwright-mcp in WSL2 to Windows Chrome";
    homepage = "https://github.com/pigochu/wsl-chrome-bridge";
    license = lib.licenses.asl20;
    mainProgram = "wsl-chrome-bridge";
  };
}