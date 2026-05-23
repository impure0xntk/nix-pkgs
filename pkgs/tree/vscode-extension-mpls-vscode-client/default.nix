{ pkgs, lib, ... }:
let
  vsix = pkgs.stdenv.mkDerivation (finalAttrs: {
    name = "mpls-vscode-client-${finalAttrs.version}.vsix";
    pname = "mpls-vscode-client-vsix";
    version = "0.1.0";

    src = pkgs.fetchFromGitHub {
      owner = "mhersson";
      repo = "mpls-vscode-client";
      rev = "main";
      hash = "sha256-KCrgn2p6XrXgnE46lCabchZdbUx4E2nSAl2PZhZcf0E=";
    };
    nativeBuildInputs = with pkgs; [
      nodejs
      npmHooks.npmConfigHook
      typescript
      vsce
    ];

    npmDeps = pkgs.fetchNpmDeps {
      name = "${finalAttrs.pname}-npm-deps";
      inherit (finalAttrs) src;
      hash = "sha256-8HgpzKrlIWgdcGgvtwIU+0LK+xqnbX1zTSQxdjs1qtU=";
    };
    strictDeps = true;

    buildPhase = ''
      runHook preBuild

      npm run compile
      vsce package

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      cp ./mpls-vscode-client-$version.vsix $out
      runHook postInstall
    '';
  });
in
pkgs.vscode-utils.buildVscodeExtension (finalAttrs: rec {
  pname = "mpls-vscode-client";
  inherit (finalAttrs.src) version;

  src = vsix;

  vscodeExtPublisher = "mhersson";
  vscodeExtName = pname;
  vscodeExtUniqueId = "${vscodeExtPublisher}.${vscodeExtName}";

  unpackPhase = ''
    runHook preUnpack

    mkdir source
    cd source
    unzip ${src}

    runHook postUnpack
  '';

  passthru = {
    vsix = finalAttrs.src; # for code-install-extensions
    updateScript = pkgs.nix-update-script {
      attrPath = "vscode-extensions.${vscodeExtUniqueId}.vsix";
    };
  };

  meta = with lib; {
    description = "VSCode extension for mpls";
    homepage = "https://github.com/mhersson/mpls-vscode-client";
    license = licenses.mit;
    platforms = platforms.all;
  };
})
