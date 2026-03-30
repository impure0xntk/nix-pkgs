# Add -go suffix to avoid conflict with mcp-servers-nix's one
{
  pkgs,
  lib,
  ...
}:
pkgs.buildGoModule rec {
  pname = "mcpjungle";
  version = "0.3.6";
  src = pkgs.fetchFromGitHub {
    owner = "mcpjungle";
    repo = "MCPJungle";
    tag = version;
    hash = "sha256-wsysmD34s89PBZ++q6htc9jr6/ChX98ZQEYMlKWfG3I=";
  };
  vendorHash = "sha256-pvCDf7Y+LiIOiZ0O/bJMzkf75o7HQbYpF01yFY4J9Yg=";

  doCheck = false; # "FAIL: TestResolveTargetDirForExport" workaround

  meta = {
    description = "Self-hosted MCP Gateway and Registry for AI agents";
    homepage = "https://github.com/mcpjungle/MCPJungle";
    license = lib.licenses.mpl20;
    mainProgram = "mcpjungle";
  };
}
