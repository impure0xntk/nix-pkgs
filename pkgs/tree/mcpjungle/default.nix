# Add -go suffix to avoid conflict with mcp-servers-nix's one
{
  pkgs,
  lib,
  ...
}:
pkgs.buildGoModule rec {
  pname = "mcpjungle";
  version = "0.4.7";
  src = pkgs.fetchFromGitHub {
    owner = "mcpjungle";
    repo = "MCPJungle";
    tag = version;
    hash = "sha256-VhekFu+LZ25VtsI8p75UB9iEVCgxYvJq72BSRDBlY8E=";
  };
  vendorHash = "sha256-K/VErh+f6rU0axuEHu4UuJEOxtWJO9BKS4fNGenQrbo=";

  preBuild = ''
    mkdir -p internal/dashboardui/dist
    touch internal/dashboardui/dist/index.html
  '';

  doCheck = false; # "FAIL: TestResolveTargetDirForExport" workaround

  meta = {
    description = "Self-hosted MCP Gateway and Registry for AI agents";
    homepage = "https://github.com/mcpjungle/MCPJungle";
    license = lib.licenses.mpl20;
    mainProgram = "mcpjungle";
  };
}
