{
  pkgs,
  lib,
  ...
}:
pkgs.rustPlatform.buildRustPackage rec {
  pname = "lean-ctx";
  version = "3.10.1";

  src = pkgs.fetchFromGitHub {
    owner = "yvgude";
    repo = "lean-ctx";
    rev = "v${version}";
    hash = "sha256-qdWpPsSupKnyG/6joHCFGe+snWwRMS8ZuN4de7a2vtU=";
  };

  # The workspace lives under `rust/`. Build only the main binary and skip
  # the optional grammar-addon cdylibs and `dev-tools`-gated examples.
  sourceRoot = "source/rust";
  cargoBuildFlags = [ "--bin" "lean-ctx" ];

  cargoHash = "sha256-pDKE8Dfl75Zau67DbQ5gXelF6yxrI3NzTv+Y5mTWkEQ=";

  # The Engine crate is large; skip the second compile pass during checkPhase.
  doCheck = false;

  meta = {
    description = "Local context engine, CLI, MCP server, and proxy for AI agents";
    homepage = "https://github.com/yvgude/lean-ctx";
    license = lib.licenses.asl20;
    mainProgram = "lean-ctx";
  };
}
