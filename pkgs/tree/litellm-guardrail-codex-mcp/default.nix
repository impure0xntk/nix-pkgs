# Workaround od https://github.com/openai/codex/issues/26234
{
  pkgs,
  lib,
  ...
}:
let
  src = pkgs.fetchFromGitHub {
    owner = "impure0xntk";
    repo = "LiteLLM-Guardrail-Codex-MCP";
    rev = "f25263ba42ae252f5ac9d0a8c7f573a683cfc050"; # main @ 2026-10-17
    hash = "sha256-JmsV/SsH8TRCBxP2bzT0IhlD7vBNNEEM0NYxS890sQo=";
  };
  pythonPackages = pkgs.unstable.python313Packages;
in
pythonPackages.callPackage "${src}/nix/package.nix" {
  litellm = pythonPackages.litellm;
}
