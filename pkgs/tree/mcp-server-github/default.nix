{
  pkgs,
  lib,
  ...
}:
pkgs.buildGoModule (finalAttrs: {
  pname = "mcp-server-github";
  version = "0.13.0";

  src = pkgs.fetchFromGitHub {
    owner = "github";
    repo = "github-mcp-server";
    tag = "v${finalAttrs.version}";
    hash = "sha256-E1ta3qt0xXOFw9KhQYKt6cLolJ2wkH6JU22NbCWeuf0=";
  };
  vendorHash = "sha256-F6PR4bxFSixgYQX65zjrVxcxEQxCoavQqa5mBGrZH8o=";

  meta = {
    description = "GitHub's official MCP Server";
    homepage = "https://github.com/github/github-mcp-server";
    license = lib.licenses.mit;
    mainProgram = "github-mcp-server";
  };
})
