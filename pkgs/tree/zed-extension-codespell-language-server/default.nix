{
  pkgs,
  lib,
  ...
}:
pkgs.buildZedRustExtension (finalAttrs: rec {
  name = "codespell-language-server";
  version = "0.1.1";

  src = pkgs.fetchFromGitHub {
    owner = "impure0xntk";
    repo = "zed-${name}";
    rev = "v${version}";
    hash = "sha256-NzsHekhiWfguiwXeYqOR5DNexpWLdRjG0U0iQTaK71A=";
  };

  cargoHash = "sha256-4LUVYV6Y1n0n1Ve+Hk39OD6opkqGB7O3VGXogcdRGm0=";
})
