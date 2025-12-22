{
  pkgs,
  lib,
  ...
}:
let
  rev = "03ff84a16a7fbd4a6ff82ecc42807c3ad45fa60c"; # Dec 20 2025
in
pkgs.stdenvNoCC.mkDerivation {
  pname = "git-gtr";
  version = "2.0.0-${rev}";

  src = pkgs.fetchFromGitHub {
    owner = "coderabbitai";
    repo = "git-worktree-runner";
    inherit rev;
    hash = "sha256-mgAt6GXba43nBOQOznLhCXwOEyjtrXiM/f0JSXfaE5s=";
  };

  nativeBuildInputs = with pkgs; [ makeWrapper ];

  dontBuild = true;

  installPhase = ''
    mkdir -p $out/{bin,share/git-gtr}

    cp -r bin lib adapters completions templates $out/share/git-gtr/

    makeWrapper $out/share/git-gtr/bin/git-gtr $out/bin/git-gtr \
      --prefix PATH : ${lib.makeBinPath (with pkgs; [
        git
        coreutils
        gnused
        gnugrep
        findutils
        gawk
      ])}
  '';

  meta = {
    description = "A portable, cross-platform CLI for managing git worktrees with ease";
    homepage = "https://github.com/coderabbitai/git-worktree-runner";
    license = lib.licenses.asl20;
    mainProgram = "git-gtr";
  };
}