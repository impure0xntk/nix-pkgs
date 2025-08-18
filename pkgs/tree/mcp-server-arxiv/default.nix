# https://github.com/timblaktu/mcp-servers-nix/blob/6bd16cd70225afeb6278b2489b79d2f356b9acd2/pkgs/official/mcp-nixos/default.nix
{
  pkgs,
  lib,
  ...
}:
let
  # TODO: move to overlay
  pymupdf4llm = pkgs.python3Packages.buildPythonPackage rec {
    pname = "pymupdf4llm";
    version = "0.0.17";
    pyproject = true;

    src = pkgs.fetchFromGitHub {
      owner = "pymupdf";
      repo = "RAG";
      tag = "v${version}";
      hash = "sha256-+RLK+UorkU8eVQJGrc7pVNZPtIpxMgA9mBKA6GeWUa0=";
    };

    sourceRoot = "${src.name}/pymupdf4llm";

    build-system = [ pkgs.python3Packages.setuptools ];

    dependencies = [ pkgs.python3Packages.pymupdf ];

    checkPhase = ''
      runHook preCheck

      python3 - <<'EOF'
      import fitz
      import pymupdf4llm

      doc = fitz.open()
      page = doc.new_page()
      page.insert_text((72, 72), "Hello, Nix!")
      doc.save("input.pdf")

      md = pymupdf4llm.to_markdown("input.pdf")
      assert isinstance(md, str), "Returned value is not a string"
      assert "Hello, Nix!" in md, "Returned value does not contain the expected text"
      EOF

      runHook postCheck
    '';

    pythonImportsCheck = [ "pymupdf4llm" ];

    meta = {
      description = "PyMuPDF Utilities for LLM/RAG - converts PDF pages to Markdown format for Retrieval-Augmented Generation";
      homepage = "https://github.com/pymupdf/RAG";
      changelog = "https://github.com/pymupdf/RAG/blob/${src.tag}/CHANGES.md";
      license = lib.licenses.agpl3Only;
      maintainers = with lib.maintainers; [ ryota2357 ];
    };
  };
in
pkgs.python3Packages.buildPythonApplication rec {
  pname = "mcp-server-arxiv";
  version = "0.3.0";

  src = pkgs.fetchFromGitHub {
    owner = "blazickjp";
    repo = "arxiv-mcp-server";
    rev = "cfb327acf8fffb49417d6381e4a9cd47761a1da3";
    hash = "sha256-709e/l3xhd+u+q45HA2LWxJAG7nNk6V9wx2ZuUT/YFU=";
  };

  pyproject = true;

  build-system = with pkgs.python3Packages; [
    hatchling
  ];

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
