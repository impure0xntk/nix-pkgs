# This derivation is not used directly.
# However, it is kept in the repository
# because it is useful for editing package-lock.json.
{
  pkgs,
  lib,
  ...
}:
pkgs.buildNpmPackage rec {
  pname = "mcp-server-vscode";
  version = "0.3.0";
  src = pkgs.fetchFromGitHub {
    owner = "juehang";
    repo = "vscode-mcp-server";
    rev = version;
    hash = "sha256-rYsJ9af5a4spbkXVQk7PL4agG13eEUXtf9J8H0oGvhA=";
  };

  # Edit modelcontextprotocol/inspector information: cannot use resolved url as git+ssh://...
  #
  # Use lib.recursiveUpdate to merge. not use mkMerge, mergeAttrsList and etc...
  npmDeps =
    let
      mcp-inspector = {
        version = "0.16.6";
        hash = "sha256-1HvjFYEFLv6aoI64lGAHznOeTR0J5leat+UOPkTXObo=";
      };
    in
    pkgs.importNpmLock {
      package = lib.recursiveUpdate (lib.importJSON "${src}/package.json") {
        dependencies."@modelcontextprotocol/inspector" = "^${mcp-inspector.version}";
      };
      packageLock = lib.recursiveUpdate (lib.importJSON "${src}/package-lock.json") {
        packages = {
          "".dependencies."@modelcontextprotocol/inspector" = "^${mcp-inspector.version}";
          "node_modules/@modelcontextprotocol/inspector" = {
            resolved = "https://registry.npmjs.org/@modelcontextprotocol/inspector/-/inspector-${mcp-inspector.version}.tgz";
            integrity = mcp-inspector.hash;
          };
        };
      };
    };

  npmConfigHook = pkgs.importNpmLock.npmConfigHook;

  buildInputs = with pkgs; [
    # For keytar
    libsecret
  ];

  nativeBuildInputs = with pkgs; [
    nodejs
    typescript
    # For keytar
    pkg-config
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    cp -r node_modules $out/
    cp -r out $out/
    echo '#!${pkgs.bash}/bin/bash' > $out/bin/mcp-server-vscode
    echo "export NODE_PATH=$out/node_modules; ${pkgs.nodejs}/bin/node $out/out/server.js \"\$@\"" >> $out/bin/mcp-server-vscode
    chmod +x $out/bin/mcp-server-vscode

    runHook postInstall
  '';

  npmBuildScript = "compile";

  dontCheckForBrokenSymlinks = true;

  meta = {
    description = "MCP server to expose VS Code editing features to an LLM for AI coding";
    homepage = "https://github.com/juehang/vscode-mcp-server";
    license = lib.licenses.mit;
    mainProgram = "mcp-server-vscode";
  };
}
