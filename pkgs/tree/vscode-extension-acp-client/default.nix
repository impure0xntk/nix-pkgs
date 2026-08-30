{ pkgs, lib, ... }:
let
  vsix = pkgs.stdenv.mkDerivation (finalAttrs: {
    pname = "vscode-acp-client-vsix";
    version = "0.1.0";
    name = "${finalAttrs.pname}-${finalAttrs.version}.vsix";

    src = pkgs.fetchFromGitHub {
      owner = "impure0xntk";
      repo = "vscode-acp-client";
      rev = "main"; # 2026/08/30
      hash = "sha256-jARKQ+bcOrd0BHUGF4v42jKVxqoVdCh6rH0fSfxQbfA=";
    };
    nativeBuildInputs = with pkgs; [
      nodejs
      python3
      pkg-config
      unzip
      npmHooks.npmConfigHook
      typescript
      vsce
    ];
    buildInputs = with pkgs; [
      libsecret
    ];

    npmDeps = pkgs.fetchNpmDeps {
      name = "vscode-acp-client-vsix-npm-deps";
      src = finalAttrs.src;
      hash = "sha256-mfSWnATnk/XXSQbCufFohm6kZV4tD3A0QI1i821LNp0=";
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
      cp ./vscode-acp-client-0.1.0.vsix $out
      runHook postInstall
    '';
  });
in
pkgs.vscode-utils.buildVscodeExtension (finalAttrs: rec {
  pname = "vscode-acp-client";
  inherit (finalAttrs.src) version;

  src = vsix;

  vscodeExtPublisher = "vscode-acp-client";
  vscodeExtName = pname;
  vscodeExtUniqueId = "${vscodeExtPublisher}.${vscodeExtName}";

  nativeBuildInputs = [ pkgs.unzip ];

  unpackPhase = ''
    runHook preUnpack

    mkdir source
    cd source
    unzip ''${src}

    runHook postUnpack
  '';

  passthru = {
    vsix = src; # for code-install-extensions
    updateScript = pkgs.nix-update-script {
      attrPath = "vscode-extensions.''${vscodeExtUniqueId}.vsix";
    };
  };

  meta = with lib; {
    description = "Universal ACP client for VS Code - multi-agent chat with rich context";
    homepage = "https://github.com/impure0xntk/vscode-acp-client";
    license = licenses.mit;
    platforms = platforms.all;
  };
})
