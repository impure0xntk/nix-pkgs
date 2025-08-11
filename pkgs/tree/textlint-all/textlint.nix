# How to override buildNpmPackage: https://discourse.nixos.org/t/overlay-to-change-buildnpmpackage-version-with-flakes/57960/2
# Recent textlint uses pnpm so must replace buildNpmPackage to std.mkDerivation and pnpm.
{ pkgs, ... }:
pkgs.textlint.overrideAttrs (
  final: prev: {
    version = "15.2.1";
    src = prev.src.override {
      tag = "v${final.version}";
      hash = "sha256-xjtmYz+O+Sn697OrBkPddv1Ma5UsOkO5v4SGlhsaYWA=";
    };
    pnpmDeps = pkgs.pnpm.fetchDeps {
      pname = final.pname;
      version = final.version;
      src = final.src;
      hash = "sha256-GWnBZJJt9nu6sdsWWv6u5ALxnLYhgd9hy6S54eRr9Dw=";
    };

    nativeBuildInputs = with pkgs; [
      nodejs
      pnpm.configHook
      typescript

      coreutils
    ];

    postPatch = ''
      sed -i \
        -e '/examples/d' \
        -e '/test/d' \
        -e '/website/d' \
        pnpm-workspace.yaml
    '';

    # Use pnpm -r option to build all packages in workspace.
    buildPhase = ''
      runHook preBuild

      pnpm -r build

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/{bin,lib}

      cp -r node_modules $out/lib
      cp -r packages $out/lib
      ln -s $out/lib/packages/textlint/bin/textlint.js $out/bin/textlint

      runHook postInstall
    '';

    patches = [ ];
  }
)
