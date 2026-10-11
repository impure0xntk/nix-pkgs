{
  pkgs,
  lib,
  ...
}:
pkgs.buildZedRustExtension (finalAttrs: rec {
  name = "xml-language-server";
  version = "0.1.0";

  src = pkgs.fetchFromGitHub {
    owner = "impure0xntk";
    repo = "zed-${name}";
    rev = "ef1f98d1f7399712cdd731c228f1a589c6e3846e";
    hash = "sha256-uArl8NSaqqvVFw4lsf2O/OPM+MG74cBELzLe+zxLYZU=";
  };

  cargoHash = "sha256-5HULYrKFGMFa8t5BvBKmDIVk8Fjff8/6KQ6AOLyW2G0=";
})
