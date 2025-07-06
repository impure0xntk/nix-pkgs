# TODO: consider to remove this and replace to nixpkgs after releasing NixOS 25.05
{ pkgs, prev, jre, ... }:
prev.pmd.overrideAttrs(old: rec { # check support java version. In NixOS 25.05, supports java 20.
  # https://github.com/NixOS/nixpkgs/issues/381499#issue-2848786108
  version = "7.12.0";
  src = pkgs.fetchurl {
    url = "https://github.com/pmd/pmd/releases/download/pmd_releases/${version}/pmd-dist-${version}-bin.zip";
    hash = "sha256-QY3YGdOKFqSdfzRe+aClHp9T6Z8CLYsHIt53twSbuLg=";
  };
  # Now for only IDE, so subcommands like cpd, etc.. cannot use.
  # If you want to use them, call makeWrapper as old,
  # but if call it, "pmd check" for IDE does not work.
  installPhase = ''
    runHook preInstall

    install -Dm755 bin/pmd $out/bin/pmd
    install -Dm644 lib/*.jar -t $out/lib/pmd
    install -Dm222 conf/* -t $out/conf

    wrapProgram $out/bin/pmd \
      --prefix PATH : ${jre}/bin \
      --set LIB_DIR $out/lib/pmd

    runHook postInstall
  '';
})
