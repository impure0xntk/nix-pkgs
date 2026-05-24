# If fails to install, try to update flake for root project
{pkgs, lib, ...}:
let
  codebook = pkgs.unstable.codebook;

  vsix = pkgs.stdenv.mkDerivation (finalAttrs: {
    pname = "codebook-vscode-${finalAttrs.version}-vsix";
    inherit (codebook) version;

    src = "${codebook.src}/editors/vscode";

    nativeBuildInputs = with pkgs; [
      nodejs
      bun
      typescript
      esbuild
      vsce

      bun2nix.hook
    ];
    bunDeps = pkgs.bun2nix.fetchBunDeps {
      bunNix = "${
        pkgs.runCommand "bun-nix" { } ''
          mkdir $out
          ${lib.getExe pkgs.bun2nix} -l ${finalAttrs.src}/bun.lock -o $out/bun.nix
        ''
      }/bun.nix";
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