# https://github.com/timblaktu/mcp-servers-nix/blob/6bd16cd70225afeb6278b2489b79d2f356b9acd2/pkgs/official/mcp-nixos/default.nix
{
  pkgs,
  lib,
  ...
}:
let
  markitdown = pkgs.markitdown;
in
pkgs.python3Packages.buildPythonApplication rec {
  pname = "mcp-server-markitdown";
  version = markitdown.version;

  src = "${pkgs.markitdown.srcRoot}/packages/markitdown-mcp";

  pyproject = true;

  build-system = with pkgs.python3Packages; [
    hatchling
  ];

  dependencies = with pkgs.python3Packages; [
    mcp
    markitdown
  ];

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'dynamic = ["version"]' \
        'version = "${version}"' \
      --replace-fail '"mcp~=1.8.0",' \
        '"mcp>=1.8.0",'
  '';

  # Disable tests for now - can enable once we know the test structure
  doCheck = false;

  meta = {
    description = "Python tool for converting files and office documents to Markdown.";
    homepage = "https://github.com/microsoft/markitdown";
    license = lib.licenses.mit;
    mainProgram = "markitdown-mcp";
  };
}
