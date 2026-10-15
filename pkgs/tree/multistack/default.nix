{
  pkgs,
  lib,
  ...
}:
let
  rustPlatform = pkgs.unstable.rustPlatform;
in
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "multistack";
  version = "1.1.5";
  src = pkgs.fetchFromGitHub {
    owner = "gi-dellav";
    repo = "multistack";
    tag = "v${finalAttrs.version}";
    hash = "sha256-WFP3y4d3MK1BQdUWQsu3QtGyMo4xac6q0TzRUaEg1Gg=";
  };
  cargoHash = "sha256-pn3OpAHuSb5JCNsqrVT8KAmaoG5160O8QZt0gvW5Frc=";
  meta = {
    description = "Open source lightweight TUI for parallel agent management";
    homepage = "https://github.com/gi-dellav/multistack";
    license = lib.licenses.gpl3_0_only;
    mainProgram = "multistack";
  };
})
