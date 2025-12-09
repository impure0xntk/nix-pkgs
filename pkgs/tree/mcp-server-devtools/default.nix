# Add -go suffix to avoid conflict with mcp-servers-nix's one
{
  pkgs,
  lib,
  ...
}:
pkgs.buildGoModule (self: rec { # TODO: remove buildGo"125"Module after NixOS 25.11 to use go latest
  pname = "mcp-server-devtools";
  version = "0.44.4";

  src = pkgs.fetchFromGitHub {
    owner = "sammcj";
    repo = "mcp-devtools";
    tag = "v${version}";
    hash = "sha256-fqrh9lV6/scXOPVY7cgUeQLOcoivfeyhM63jd4763Jg=";
  };
  vendorHash = "sha256-MVCkU+Bpu27sSPYYkqB8EQnjH/eW1HUn6FFoy4okLpc=";

  doCheck = false; # some deps try to connect internet

  meta = {
    description = "A modular MCP server that provides commonly used developer tools for AI coding agents";
    homepage = "https://github.com/sammcj/mcp-devtools";
    license = lib.licenses.asl20;
    mainProgram = "mcp-devtools";
  };
})
