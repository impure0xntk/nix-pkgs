{
  pkgs,
  lib,
  ...
}:
pkgs.buildNpmPackage rec {
  pname = "codegraph";
  version = "1.6.0";

  src = pkgs.fetchFromGitHub {
    owner = "colbymchenry";
    repo = "codegraph";
    rev = "v${version}";
    hash = "sha256-Lr8J8/E/o4tECLe/uv0W2H6zD74+TH/431I2iIYZ2no=";
  };

  npmDeps = pkgs.importNpmLock {
    npmRoot = src;
  };

  npmConfigHook = pkgs.importNpmLock.npmConfigHook;

  meta = {
    description = "Semantic code intelligence CLI for AI coding agents";
    homepage = "https://github.com/colbymchenry/codegraph";
    license = lib.licenses.mit;
    mainProgram = "codegraph";
  };
}
