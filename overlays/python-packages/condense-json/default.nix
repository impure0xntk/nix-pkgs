# TODO: remove after NixOS 25.11
{
  final,
  prev,
  pyself,
  pysuper,
  ...
}:
pysuper.condense-json.overridePythonAttrs (old: rec {
  version = "0.1.3";
  src = prev.fetchFromGitHub {
    owner = "simonw";
    repo = "condense-json";
    tag = version;
    hash = "sha256-vMh6GLWqae0Ave3FmrGQuVCgFzYMGCIe76mGNDMrBdU=";
  };
})
