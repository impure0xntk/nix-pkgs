# For llm tools: https://github.com/simonw/llm/issues/1105#issuecomment-2918029450
# TODO: remove after NixOS 25.11
{
  final,
  prev,
  pyself,
  pysuper,
  ...
}:
pysuper.llm-ollama.overridePythonAttrs (old: rec {
  version = "0.11.0";
  src = prev.fetchFromGitHub {
    owner = "taketwo";
    repo = "llm-ollama";
    tag = version;
    hash = "sha256-iwrDqrPt/zwXypBwD7zDAcen4fQq6PXl7Xj5VUL2KWA=";
  };
})