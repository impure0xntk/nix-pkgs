# https://github.com/timblaktu/mcp-servers-nix/blob/6bd16cd70225afeb6278b2489b79d2f356b9acd2/pkgs/official/mcp-nixos/default.nix
{
  pkgs,
  lib,
  # buildUvPackage,
  ...
}:

let
  pythonPkgs = pkgs.unstable.python3Packages;
  version = "0.4.12";
  src = pkgs.fetchFromGitHub {
    owner = "blazickjp";
    repo = "arxiv-mcp-server";
    rev = "v${version}";
    hash = "sha256-FkK3RsRsMzvyWTJ3opUsu6mA6qfptdIbr31nN0SPz4U=";
  };

  arxiv = pythonPkgs.arxiv.overridePythonAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pythonPkgs.pythonRelaxDepsHook ];
    pythonRelaxDeps = [ "requests" ];
  });

  # https://github.com/ZarredFelicite/nixos/blob/ab82bb718753fc59f34e78af519d6eb5c1d1c4af/pkgs/python/pymupdf-layout/default.nix#L10
  pymupdf-layout = let
    layoutWheel = pkgs.fetchurl {
      url = "https://files.pythonhosted.org/packages/a7/bd/3e049b359dd0c3a101ae915484b87ff73bfdedfb24a924e0a8e6783b33f3/pymupdf_layout-1.26.6-cp310-abi3-manylinux_2_28_x86_64.whl";
      sha256 = "sha256-7o4r/tEtS2QhsnofiYN6wJ2Lw/eD95Zw2zl+wkYUvz0=";
    };
  in pythonPkgs.pymupdf.overridePythonAttrs (old: {
    pname = "pymupdf-layout";
    version = "1.26.6";

    nativeBuildInputs = (old.nativeBuildInputs or []) ++ [ pkgs.unzip ];
    propagatedBuildInputs = (old.propagatedBuildInputs or []) ++ (with pythonPkgs; [
      pyyaml
      numpy
      onnxruntime
      networkx
    ]);
    
    postInstall = (old.postInstall or "") + ''
      tmpdir="$(mktemp -d)"
      unzip -q ${layoutWheel} -d "$tmpdir"
      mkdir -p "$out/${pkgs.python3.sitePackages}/pymupdf"
      cp -R "$tmpdir/pymupdf/layout" "$out/${pkgs.python3.sitePackages}/pymupdf/"
      cp -f "$tmpdir/pymupdf/features.py" "$out/${pkgs.python3.sitePackages}/pymupdf/features.py"
      cp -f "$tmpdir/pymupdf/_features.so" "$out/${pkgs.python3.sitePackages}/pymupdf/_features.so"
      
      cp -R \
        "$tmpdir"/pymupdf_layout-*.dist-info \
        "$out/${pythonPkgs.python.sitePackages}/"
    '';

    # Upstream memory regression test is flaky under Nix/CI on Python 3.13.
    # Keep checks enabled but skip this known non-deterministic case.
    disabledTests = (old.disabledTests or []) ++ [ "test_2791" ];
  }) ;

in
# Cannot build via uv
# buildUvPackage {
#   pname = "mcp-server-arxiv";
#   inherit src;
# }
pythonPkgs.buildPythonApplication {
  pname = "mcp-server-arxiv";
  inherit version src;

  pyproject = true;

  build-system = with pythonPkgs; [
    hatchling
  ];

  # Remove unused dependencies
  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail '"black>=25.1.0",' ""
  '';

  dependencies = with pythonPkgs; [
    arxiv
    httpx
    python-dateutil
    pydantic
    mcp
    aiohttp
    python-dotenv
    pydantic-settings
    aiofiles
    uvicorn
    starlette
    sse-starlette
    anyio
    pymupdf-layout
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
