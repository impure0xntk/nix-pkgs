# https://github.com/Jorgedavyd/nix-dev/blob/9b4ce9e733232bd92650a7295ca3ad7ddc1fe45f/flake.nix#L9
# TODO: remove after NixOS 25.11
{
  final,
  prev,
  pyself,
  pysuper,
  ...
}:
pysuper.llm.overridePythonAttrs (old: rec {
  version = "0.26";
  src = prev.fetchFromGitHub {
    owner = "simonw";
    repo = "llm";
    tag = version;
    hash = "sha256-KTlNajuZrR0kBX3LatepsNM3PfRVsQn+evEfXTu6juE=";
  };
  patches = [./001-disable-install-uninstall-commands.patch];

  doCheck = false;
})
