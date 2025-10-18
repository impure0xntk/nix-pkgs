# Add -go suffix to avoid conflict with mcp-servers-nix's one
{
  pkgs,
  lib,
  ...
}:
pkgs.buildGo125Module (self: rec { # TODO: remove buildGo"125"Module after NixOS 25.11 to use go latest
  pname = "mcp-server-devtools";
  version = "0.40.7";

  src = pkgs.fetchFromGitHub {
    owner = "sammcj";
    repo = "mcp-devtools";
    tag = "v${version}";
    hash = "sha256-HR1Nh1MFRRIGH2D4TAlvhMH9CN6FOErUL9MvcI1kXbM=";
  };
  vendorHash = "sha256-F6/U7cU9L3+I5ragr6BdG5z/nomVwiQZujNs13Y3oo4=";

  doCheck = false; # some deps try to connect internet

  meta = {
    description = "A modular MCP server that provides commonly used developer tools for AI coding agents";
    homepage = "https://github.com/sammcj/mcp-devtools";
    license = lib.licenses.asl20;
    mainProgram = "mcp-devtools";
  };
})
