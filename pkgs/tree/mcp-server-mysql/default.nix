{
  pkgs,
  lib,
  ...
}:
pkgs.buildNpmPackage rec {
  pname = "mcp-server-mysql";
  version = "2.0.5";
  src = pkgs.fetchFromGitHub {
    owner = "benborla";
    repo = pname;
    rev = "v${version}";
    hash = "sha256-gfhxmDoSoABx6oibsOy91sfzIIOP34OJtzkvYoVIYKY=";
  };

  npmDeps = pkgs.importNpmLock {
    npmRoot = src;
  };

  npmConfigHook = pkgs.importNpmLock.npmConfigHook;

  nativeBuildInputs = with pkgs; [
    typescript
  ];

  dontCheckForBrokenSymlinks = true;

  meta = {
    description = "A Model Context Protocol server that provides read-only access to MySQL databases. This server enables LLMs to inspect database schemas and execute read-only queries.";
    homepage = "https://github.com/benborla/mcp-server-mysql";
    license = lib.licenses.mit;
    mainProgram = "mcp-server-mysql";
  };
}