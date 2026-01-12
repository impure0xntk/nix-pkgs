# Add -go suffix to avoid conflict with mcp-servers-nix's one
{
  pkgs,
  lib,
  ...
}:
pkgs.pure-unstable.buildGoModule (self: rec {
  pname = "mcp-server-devtools";
  version = "0.59.3";

  src = pkgs.fetchFromGitHub {
    owner = "sammcj";
    repo = "mcp-devtools";
    tag = "v${version}";
    hash = "sha256-5Ljns7ZiypFm2CMjQz6MHw731JE3EURNSPfdjfoeXEs=";
  };
  vendorHash = "sha256-hPpu8a0ExdZk33xRFZUp+Vc4xPpNpO4UPOW1wqDZsHY=";

  # tests/benchmarks build failure workaround
  preBuild = ''
    rm -rf tests
  '';

  doCheck = false; # some deps try to connect internet

  meta = {
    description = "A modular MCP server that provides commonly used developer tools for AI coding agents";
    homepage = "https://github.com/sammcj/mcp-devtools";
    license = lib.licenses.asl20;
    mainProgram = "mcp-devtools";
  };
})
