# Add -go suffix to avoid conflict with mcp-servers-nix's one
{
  pkgs,
  lib,
  ...
}:
pkgs.buildGoModule rec {
  pname = "mcpjungle";
  version = "0.2.8";
  src = pkgs.fetchFromGitHub {
    owner = "mcpjungle";
    repo = "MCPJungle";
    tag = version;
    hash = "sha256-DFWLqkjX8YLE9veLrPyxW3wkjJqDrtoOvnU1+UrqPX4=";
  };
  vendorHash = "sha256-XpYG11WeX0AX6FDcl4YjveDaZ3vwK2oUNDutMRTqIUc=";

  meta = {
    description = "Self-hosted MCP Gateway and Registry for AI agents";
    homepage = "https://github.com/mcpjungle/MCPJungle";
    license = lib.licenses.mpl20;
    mainProgram = "mcpjungle";
  };
}
