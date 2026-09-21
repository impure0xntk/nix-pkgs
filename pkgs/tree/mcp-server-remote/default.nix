# https://github.com/PsycheFoundation/psyche/blob/b4ca1f357834e4f333b3911e3443b6d3bc21dafb/website/common.nix
{
  pkgs,
  lib,
  ...
}:
pkgs.stdenv.mkDerivation rec {
  pname = "mcp-server-remote";
  version = "0.14.2";
  src = pkgs.fetchFromGitHub {
    owner = "punkpeye";
    repo = "mcp-remote";
    rev = "v${version}";
    hash = "sha256-b3IEAVwxTb2c/2ENRgQqluuZ5BE3alXsqProDwWQ1eA=";
  };

  pnpmDeps = pkgs.fetchPnpmDeps {
    inherit pname version src;
    fetcherVersion = 4;
    hash = "sha256-h1Rh3xDw6mpCBWfh+fjfWtZ8WrdziEL2d6S+k9VaghQ=";
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
    echo '#!${pkgs.bash}/bin/bash' > $out/bin/mcp-remote
    echo "export NODE_PATH=$out/node_modules; ${pkgs.nodejs}/bin/node $out/dist/proxy.js \"\$@\"" >> $out/bin/mcp-remote
    chmod +x $out/bin/mcp-remote

    runHook postInstall
  '';

  dontCheckForBrokenSymlinks = true;

  meta = {
    description = "Connect an MCP Client that only supports local (stdio) servers to a Remote MCP Server, with auth support:";
    homepage = "https://github.com/geelen/mcp-remote";
    license = lib.licenses.mit;
    mainProgram = "mcp-remote";
  };
}
