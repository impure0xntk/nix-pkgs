{ pkgs, lib, ... }:

pkgs.buildNpmPackage rec {
  pname = "mcp-server-caldav";
  version = "0.10.0";
  src = pkgs.fetchFromGitHub {
    owner = "dominik1001";
    repo = "caldav-mcp";
    rev = "v${version}";
    hash = "sha256-P7WViU0LjVby5YmHxClBXfckGqRVpv6Oml+BPb6ywL4=";
  };

  npmDeps = pkgs.importNpmLock {
    package = lib.importJSON "${src}/package.json";
    packageLock = lib.importJSON "${src}/package-lock.json";
  };

  npmConfigHook = pkgs.importNpmLock.npmConfigHook;

  nativeBuildInputs = with pkgs; [
    typescript
    git
  ];

  # Remove lefthook prepare script that requires git repo
  postPatch = ''
    substituteInPlace package.json \
      --replace '"prepare": "lefthook install",' '"prepare": "echo \"skipping lefthook install\"",'
  '';

  dontCheckForBrokenSymlinks = true;

  meta = {
    description = "MCP server for CalDAV";
    homepage = "https://github.com/dominik1001/caldav-mcp";
    license = lib.licenses.mit;
    mainProgram = "mcp-server-caldav";
  };
}
