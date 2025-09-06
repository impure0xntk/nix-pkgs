{ pkgs, lib, ... }:

pkgs.python3Packages.buildPythonApplication rec {
  pname = "mcp-server-basic-memory";
  version = "0.14.4";

  src = pkgs.fetchFromGitHub {
    owner = "basicmachines-co";
    repo = "basic-memory";
    rev = "v${version}";
    hash = "sha256-8bCUCAS5t6MbpJ2W0Z2HJT7eBsnj6MZTjyyGBOfwif8=";
  };

  pyproject = true;

  build-system = with pkgs.python3Packages; [
    hatchling
  ];

  dependencies = with pkgs.python3Packages; [
    sqlalchemy
    pyyaml
    typer
    aiosqlite
    greenlet
    pydantic
    icecream
    mcp
    pydantic-settings
    loguru
    pyright
    markdown-it-py
    python-frontmatter
    rich
    unidecode
    dateparser
    watchfiles
    fastapi
    alembic
    pillow
    pybars3
    fastmcp
    pyjwt
    python-dotenv
    pytest-aio
  ];

  doCheck = false;

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'fastmcp==2.10.2' \
        'fastmcp>=2.10.2' \
      --replace-fail 'requires = ["hatchling", "uv-dynamic-versioning>=0.7.0"]' \
        'requires = ["hatchling"]' \
      --replace-fail 'dynamic = ["version"]' \
        'version = "${version}"'
  '';

  meta = {
    description = "Local-first knowledge management combining Zettelkasten with knowledge graphs";
    homepage = "https://github.com/basicmachines-co/basic-memory";
    license = lib.licenses.agpl3Only;
    mainProgram = "basic-memory";
  };
}