# Add -go suffix to avoid conflict with mcp-servers-nix's one
{
  pkgs,
  lib,
  ...
}:
pkgs.buildGo125Module (self: rec { # TODO: remove buildGo"125"Module after NixOS 25.11 to use go latest
  pname = "mcp-server-devtools";
  version = "0.56.4";

  src = pkgs.fetchFromGitHub {
    owner = "sammcj";
    repo = "mcp-devtools";
    tag = "v${version}";
    hash = "sha256-PVNPrRiXxLdW8jnnc9gVnJV5ZyFco8mQD4TttLnqh5k=";
  };
  vendorHash = "sha256-SsI9Wx5EB1j7F8FjcGEEkbZoO/Rx0YV6TKohkD/ElUI=";

  doCheck = false; # some deps try to connect internet

  meta = {
    description = "A modular MCP server that provides commonly used developer tools for AI coding agents";
    homepage = "https://github.com/sammcj/mcp-devtools";
    license = lib.licenses.asl20;
    mainProgram = "mcp-devtools";
  };
})
