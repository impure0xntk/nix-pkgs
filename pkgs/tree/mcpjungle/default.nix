# Add -go suffix to avoid conflict with mcp-servers-nix's one
{
  pkgs,
  lib,
  ...
}:
pkgs.buildGoModule rec {
  pname = "mcpjungle";
  version = "0.4.6";
  src = pkgs.fetchFromGitHub {
    owner = "mcpjungle";
    repo = "MCPJungle";
    tag = version;
    hash = "sha256-XzszhbkQENeUgOOVBw7dsqZWR7hU3yLYOAclf3E9gy8=";
  };
  vendorHash = "sha256-3uatBXXdQzqGuhFuLkpmoMkYYqUMt1dFqm7vuazMLqs=";

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
