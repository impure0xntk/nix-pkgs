attrs@{
  pkgs,
  uvPkgs,
  fetchFromGitHub,
  lib,
  ...
}:
let
  pname = "omnigent";
  version = "0.14.0";

  src = fetchFromGitHub {
    owner = "omnigent-ai";
    repo = "omnigent";
    rev = "v${version}";
    hash = "sha256-kU0lUX/GpBoOKgj90VRtv2+iyt3TRsthty1JopmXB2o=";
  };
  omnigentEnv = uvPkgs.buildUvPackage {
    inherit pname;
    inherit src;
    # antigravity appears in every lockfile conflict, giving uv2nix a deterministic resolution.
    dependencies = {
      omnigent = [ "antigravity" ];
    };
    pythonOverrides = final: prev: {
      # The web UI build needs a networked pnpm install; this package is CLI-only.
      omnigent = prev.omnigent.overrideAttrs (_: {
        OMNIGENT_SKIP_WEB_UI = "true";
      });
    };
  };
in
pkgs.stdenv.mkDerivation {
  inherit pname version;

  buildInputs = [ pkgs.makeWrapper ];

  buildCommand = ''
    mkdir -p $out/bin
    makeWrapper ${omnigentEnv}/bin/omni $out/bin/omni
  '';

  meta = with lib; {
    description = "Omnigent: declarative agent authoring and runtime framework";
    homepage = "https://github.com/omnigent-ai/omnigent";
    license = licenses.asl20;
    mainProgram = "omni";
  };
}
