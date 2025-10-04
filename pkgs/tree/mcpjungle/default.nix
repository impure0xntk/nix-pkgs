# Add -go suffix to avoid conflict with mcp-servers-nix's one
{
  pkgs,
  lib,
  ...
}:
pkgs.buildGoModule rec {
  pname = "mcpjungle";
  version = "0.2.14";
  src = pkgs.fetchFromGitHub {
    owner = "mcpjungle";
    repo = "MCPJungle";
    tag = version;
    hash = "sha256-rdvn9rRZrXSRShAY0V10MvC2Bj1i1If5MoSTaRYZvNg=";
  };
  vendorHash = "sha256-szv2P9qFPALSBSjlmMJTAXcXDFn/wBuSqVlxYtoXX+s=";

  meta = {
    description = "Self-hosted MCP Gateway and Registry for AI agents";
    homepage = "https://github.com/mcpjungle/MCPJungle";
    license = lib.licenses.mpl20;
    mainProgram = "mcpjungle";
  };
}
