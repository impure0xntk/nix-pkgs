# TODO: remove after NixOS 25.11
{
  final,
  prev,
  pyself,
  pysuper,
  ...
}:
pysuper.pydantic.overridePythonAttrs (old: rec {
  version = "2.11.7";
  src = final.fetchFromGitHub {
    owner = "pydantic";
    repo = "pydantic";
    tag = "v${version}";
    hash = "sha256-5EQwbAqRExApJvVUJ1C6fsEC1/rEI6/bQEQkStqgf/Q=";
  };
})
