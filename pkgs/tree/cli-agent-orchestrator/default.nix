{
  pkgs,
  lib,
  uvPkgs,
  tmux,
  ...
}:

let
  pname = "cli-agent-orchestrator";
  version = "2.5.0";

  meta = {
    description = "CLI Agent Orchestrator";
    homepage = "https://github.com/awslabs/cli-agent-orchestrator";
    license = lib.licenses.asl20;
    mainProgram = "cao";
  };

  caoEnv = (uvPkgs.buildUvPackage {
    inherit pname;

    src = pkgs.fetchFromGitHub {
      owner = "awslabs";
      repo = "cli-agent-orchestrator";
      tag = "v${version}";
      hash = "sha256-+m4qVLxDJBvcAkGFIfEn+RvY7uX9Ytrxuxg419fthE4=";
    };
  }).overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
      pkgs.makeWrapper
    ];

    postBuild = ''
      for binary in cao cao-server cao-mcp-server cao-ops-mcp-server; do
        wrapProgram "$out/bin/$binary" \
          --prefix PATH : ${lib.makeBinPath [ tmux ]}
      done
    '';
  });
in
pkgs.stdenv.mkDerivation {
  inherit pname version meta;

  buildInputs = [ pkgs.makeWrapper ];

  buildCommand = ''
    mkdir -p $out/bin
    makeWrapper ${caoEnv}/bin/cao $out/bin/cao
  '';
}
