{ pkgs, lib, ... }:
let
  vsix = pkgs.stdenv.mkDerivation (finalAttrs: {
    name = "vscode-codespell-extension-${finalAttrs.version}.vsix";
    pname = "vscode-codespell-extension-vsix";
    version = "0.1.0";

    src = pkgs.fetchFromGitHub {
      owner = "impure0xntk";
      repo = "vscode-codespell-extension";
      rev = "c1dbc636ffa77991d1060bba996eb53b40c7cc02";
      hash = "sha256-ilfTaDBeJPU++MvlM3vL8qropjeSaFuxX/LhWNrpFJo=";
    };
    nativeBuildInputs = with pkgs; [
      nodejs
      npmHooks.npmConfigHook
      typescript
      vsce

      python3
      pkg-config
    ];
    buildInputs = with pkgs; [
      libsecret
    ];

    npmDeps = pkgs.fetchNpmDeps {
      name = "${finalAttrs.pname}-npm-deps";
      inherit (finalAttrs) src;
      hash = "sha256-t14vm1TebFgJ8dw3BCuEAQHSpuOYDgM+g+ZPgasz5WE=";
    };
    strictDeps = true;

    buildPhase = ''
      runHook preBuild

      npm run build
      npm run package

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      cp ./codespell.vsix $out
      runHook postInstall
    '';
  });
in
pkgs.vscode-utils.buildVscodeExtension (finalAttrs: rec {
  pname = "codespell-extension";
  inherit (finalAttrs.src) version;

  src = vsix;

  vscodeExtPublisher = "impure0xntk";
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
    description = "A Visual Studio Code extension with support for the codespell spell checker and fixer.";
    homepage = "https://github.com/impure0xntk/vscode-codespell-extension";
    license = licenses.asl20;
    platforms = platforms.all;
  };
})
