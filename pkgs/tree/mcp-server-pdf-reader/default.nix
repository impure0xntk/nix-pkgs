{
  pkgs,
  lib,
  ...
}:
pkgs.stdenv.mkDerivation rec {
  pname = "mcp-server-pdf-reader";
  version = "0.3.23";
  src = pkgs.fetchFromGitHub {
    owner = "sylphxltd";
    repo = "pdf-reader-mcp";
    rev = "v${version}";
    hash = "sha256-XJf1W68mgtjG+YpAgrF+tIE91iv+/wIbytPF4rK3GcI=";
  };

  pnpmDeps = pkgs.pnpm.fetchDeps {
    inherit pname version src;
    fetcherVersion = 1;
    hash = "sha256-DOxuL+YCGVAC6Lz2t/CkjJ8+kIdF0Exv8rb9PihCd0s=";
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
    echo '#!${pkgs.bash}/bin/bash' > $out/bin/pdf-reader-mcp
    echo "export NODE_PATH=$out/node_modules; ${pkgs.nodejs}/bin/node $out/dist/src/index.js \"\$@\"" >> $out/bin/pdf-reader-mcp
    chmod +x $out/bin/pdf-reader-mcp
    
    runHook postInstall
  '';

  dontCheckForBrokenSymlinks = true;

  meta = {
    description = "An MCP server built with Node.js/TypeScript that allows AI agents to securely read PDF files (local or URL) and extract text, metadata, or page counts. Uses pdf-parse.";
    homepage = "https://github.com/sylphxltd/pdf-reader-mcp";
    license = lib.licenses.mit;
    mainProgram = "pdf-reader-mcp";
  };
}
