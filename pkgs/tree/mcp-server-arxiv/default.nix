# https://github.com/timblaktu/mcp-servers-nix/blob/6bd16cd70225afeb6278b2489b79d2f356b9acd2/pkgs/official/mcp-nixos/default.nix
{
  pkgs,
  lib,
  ...
}:
pkgs.python3Packages.buildPythonApplication rec {
  pname = "mcp-server-arxiv";
  version = "0.3.2";

  src = pkgs.fetchFromGitHub {
    owner = "blazickjp";
    repo = "arxiv-mcp-server";
    rev = "0065f5abb48f3eb4e011a130dd63fc52b381a1d2";
    hash = "sha256-WuPsE5YFDArtnbTL4wISfacp0IXVNi89JMRmXuX9v1s=";
  };

  pyproject = true;

  build-system = with pkgs.python3Packages; [
    hatchling
  ];

  # Remove unused dependencies
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"black>=25.1.0",' "" \
      --replace-fail '"pymupdf-layout>=1.26.6",' ""
  '';

  dependencies = with pkgs.python3Packages; [
    arxiv
    httpx
    python-dateutil
    pydantic
    mcp
    pymupdf4llm
    aiohttp
    python-dotenv
    pydantic-settings
    aiofiles
    uvicorn
    sse-starlette
    anyio
  ];

  # Disable tests for now - can enable once we know the test structure
  doCheck = false;

  meta = {
    description = "A Model Context Protocol server for searching and analyzing arXiv papers";
    homepage = "https://github.com/blazickjp/arxiv-mcp-server";
    license = lib.licenses.asl20;
    mainProgram = "arxiv-mcp-server";
  };
}
