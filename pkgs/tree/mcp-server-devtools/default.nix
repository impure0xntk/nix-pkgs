# Add -go suffix to avoid conflict with mcp-servers-nix's one
{
  pkgs,
  lib,
  ...
}:
pkgs.buildGo125Module (self: rec { # TODO: remove buildGo"125"Module after NixOS 25.11 to use go latest
  pname = "mcp-server-devtools";
  version = "0.40.10";

  src = pkgs.fetchFromGitHub {
    owner = "sammcj";
    repo = "mcp-devtools";
    tag = "v${version}";
    hash = "sha256-Zo7aJYeHL+wbsjZBRrVE4wTk8IXN/ZcpY5+pHYC11M4=";
  };
  vendorHash = "sha256-I9hC0mll47oz50Jwd3c0hyxdbq2IBNgXwh4Db7nsq2o=";

  doCheck = false; # some deps try to connect internet

  meta = {
    description = "A modular MCP server that provides commonly used developer tools for AI coding agents";
    homepage = "https://github.com/sammcj/mcp-devtools";
    license = lib.licenses.asl20;
    mainProgram = "mcp-devtools";
  };
})
