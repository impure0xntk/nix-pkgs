# https://github.com/Jorgedavyd/nix-dev/blob/9b4ce9e733232bd92650a7295ca3ad7ddc1fe45f/flake.nix#L9
# TODO: remove after NixOS 25.11
{
  final,
  prev,
  pyself,
  pysuper,
  ...
}:
final.python3Packages.buildPythonPackage rec {
  name = "fastmcp";
  version = "2.11.3";
  src = prev.fetchFromGitHub {
    owner = "jlowin";
    repo = "fastmcp";
    rev = "v${version}";
    sha256 = "sha256-jIXrMyNnyPE2DUgg+sxT6LD4dTmKQglh4cFuaw179Z0=";
  };

  pyproject = true;

  build-system = with pysuper; [
    hatchling
  ];

  dependencies = with pysuper; [
    python-dotenv
    exceptiongroup
    httpx
    mcp
    openapi-pydantic
    rich
    cyclopts
    authlib
    pydantic
    pyperclip
    openapi-core
    openai
  ];
  doCheck = false;

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'requires = ["hatchling", "uv-dynamic-versioning>=0.7.0"]' \
        'requires = ["hatchling"]' \
      --replace-fail 'dynamic = ["version"]' \
        'version = "${version}"'
  '';
}
