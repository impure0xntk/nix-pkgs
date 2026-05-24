# To pin bun.nix, use specific version: not pkgs.unstable.codebook.version
{pkgs, lib, ...}:
let
  version = "0.3.40";
  src = pkgs.fetchFromGitHub {
    owner = "blopker";
    repo = "codebook";
    rev = "v${version}";
    hash = "sha256-+tjUqo5NO1cVMW2x7eKBw8PpPVvCtURCX/+pHKWT9Z4=";
  };

  vsix = pkgs.stdenv.mkDerivation (finalAttrs: {
    name = "codebook-vscode-${finalAttrs.version}.vsix";
    pname = "codebook-vscode-vsix";
    inherit version;

    src = "${src}/editors/vscode";

    nativeBuildInputs = with pkgs; [
      nodejs
      bun
      typescript
      esbuild
      vsce

      bun2nix.hook
    ];
    bunDeps = pkgs.bun2nix.fetchBunDeps {
      # Use static pinning: cannot build if uses dynamic such as runCommand.
      bunNix = ./bun.nix;
    };

    strictDeps = true;

    buildPhase = ''
      bun run build
      npm run package
    '';

    installPhase = ''
      cp ./codebook-vscode-0.0.1.vsix $out
    '';
  });
in
pkgs.vscode-utils.buildVscodeExtension (finalAttrs: rec {
  pname = "codebook-vscode";
  inherit (finalAttrs.src) version;

  src = vsix;

  vscodeExtPublisher = "blopker";
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
    description = "A fast, code-aware spell checker — built for code, not prose.";
    homepage = "https://github.com/blopker/codebook/tree/main/editors/vscode";
    license = licenses.mit;
    platforms = platforms.all;
  };
})