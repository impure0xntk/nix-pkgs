# https://github.com/Jorgedavyd/nix-dev/blob/9b4ce9e733232bd92650a7295ca3ad7ddc1fe45f/flake.nix#L9
# TODO: remove after NixOS 25.11
{
  final,
  prev,
  pyself,
  pysuper,
  ...
}:
pysuper.mcp.overridePythonAttrs (old: rec {
  version = "1.13.1";
  src = prev.fetchFromGitHub {
    owner = "modelcontextprotocol";
    repo = "python-sdk";
    rev = "v${version}";
    sha256 = "sha256-tSC86viPDCZ6xb4lgfU7oKL176tmS3Tdx+ihP1fANhA=";
  };
  dependencies = (old.dependencies or [ ]) ++ (with pysuper; [
    python-multipart
    jsonschema
  ]);
  nativeBuildInputs = old.nativeBuildInputs or [ ] ++ [ pysuper.setuptools ];
  doCheck = false;

  postPatch = ''
    substituteInPlace pyproject.toml \
      --replace-fail 'requires = ["hatchling", "uv-dynamic-versioning"]' \
        'requires = ["hatchling"]' \
      --replace-fail 'dynamic = ["version"]' \
        'version = "${version}"' \
      || true  # Ignore substitution failures

    rm -rf static
  '';
})
