# Add -go suffix to avoid conflict with mcp-servers-nix's one
{
  pkgs,
  lib,
  ...
}:
pkgs.buildGoModule rec {
  pname = "mcpjungle";
  version = "0.2.15";
  src = pkgs.fetchFromGitHub {
    owner = "mcpjungle";
    repo = "MCPJungle";
    tag = version;
    hash = "sha256-8o6ZewsxD6SrdEBM/rzaRnD/mTqEMB/6uqTMIRxTwt4=";
  };
  vendorHash = "sha256-LOZFyUkjVpEVWzYFxStzfyL3Ls3UnwIJRNTaxd6pZNc=";

  meta = {
    description = "Self-hosted MCP Gateway and Registry for AI agents";
    homepage = "https://github.com/mcpjungle/MCPJungle";
    license = lib.licenses.mpl20;
    mainProgram = "mcpjungle";
  };
}
