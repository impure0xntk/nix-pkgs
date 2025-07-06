# https://github.com/PsycheFoundation/psyche/blob/b4ca1f357834e4f333b3911e3443b6d3bc21dafb/website/common.nix
{
  pkgs,
  lib,
  ...
}:
pkgs.stdenv.mkDerivation rec {
  pname = "mcp-server-jetbrains";
  version = "1.9.0";
  src = pkgs.fetchFromGitHub {
    owner = "JetBrains";
    repo = "mcp-jetbrains";
    rev = "v${version}";
    hash = "sha256-nxq5z6A8IhR0K65NJvfVKlhOkqV46nMa2obHsdPy+xA=";
  };

  pnpmDeps = pkgs.pnpm.fetchDeps {
    inherit pname version src;
    hash = "sha256-zdc2sm9GOojyRFUdoWWbJw9yXjArAZ4cJJ455dGQ76s=";
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
    echo '#!${pkgs.bash}/bin/bash' > $out/bin/mcp-server-jetbrains
    echo "export NODE_PATH=$out/node_modules; ${pkgs.nodejs}/bin/node $out/dist/src/index.js \"\$@\"" >> $out/bin/mcp-server-jetbrains
    chmod +x $out/bin/mcp-server-jetbrains
    
    runHook postInstall
  '';

  dontCheckForBrokenSymlinks = true;

  meta = {
    description = "A model context protocol server to work with JetBrains IDEs: IntelliJ, PyCharm, WebStorm, etc. Also, works with Android Studio";
    homepage = "https://github.com/JetBrains/mcp-jetbrains";
    license = lib.licenses.asl20;
    mainProgram = "mcp-server-jetbrains";
  };
}