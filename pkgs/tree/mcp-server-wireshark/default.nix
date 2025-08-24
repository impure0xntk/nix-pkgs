# This derivation is not used directly.
# However, it is kept in the repository
# because it is useful for editing package-lock.json.
{
  pkgs,
  lib,
  ...
}:
pkgs.stdenv.mkDerivation (finalAttrs: rec {
  pname = "mcp-server-wireshark";
  version = "0.1.0";
  src = pkgs.fetchFromGitHub {
    owner = "kriztalz";
    repo = "SharkMCP";
    rev = "5ad5ebaa9db961cfb584fa2d051ea7a2ec7a7257"; # 2025-08-24
    hash = "sha256-Ar9JUqtHtucueCS45iNbJuFzkri2Bd4L44HniJVte+o=";
  };

  pnpmDeps = pkgs.pnpm.fetchDeps {
    inherit (finalAttrs)
      pname
      version
      src
      ;
    hash = "sha256-NCjfe26Gj1FEa0YhiKjAkHp5CHZlcAFSJg2vTgNVPyI=";
  };

  npmConfigHook = pkgs.importNpmLock.npmConfigHook;

  nativeBuildInputs = with pkgs; [
    nodejs
    pnpm.configHook
    typescript
  ];

  buildPhase = ''
    pnpm run build
  '';

  # Needs tshark.
  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r node_modules $out/
    cp -r dist $out/
    echo '#!${pkgs.bash}/bin/bash' > $out/bin/mcp-server-wireshark
    echo "export PATH=$PATH:${pkgs.tshark}/bin; export NODE_PATH=$out/node_modules; ${pkgs.nodejs}/bin/node $out/dist/index.js \"\$@\"" >> $out/bin/mcp-server-wireshark
    chmod +x $out/bin/mcp-server-wireshark

    runHook postInstall
  '';

  dontCheckForBrokenSymlinks = true;

  meta = {
    description = "A tshark MCP server for packet capture and analysis";
    homepage = "https://github.com/kriztalz/sharkmcp";
    license = lib.licenses.mit;
    mainProgram = "mcp-server-wireshark";
  };
})
