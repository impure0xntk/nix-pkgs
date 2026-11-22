{ pkgs, lib, ... }:
let
  # Utopia ontology server (Rust) + web UI (pnpm).
  # Upstream: https://github.com/deeplethe/utopia
  # Released as v0.1.0-rc9; no nixpkgs package exists yet.
  version = "0.1.0-rc9";

  src = pkgs.fetchFromGitHub {
    owner = "deeplethe";
    repo = "utopia";
    rev = "v${version}";
    hash = "sha256-8vR78bUEWmo7s45FS3HprtLeHxmLto82Zz/aK9T/vPc=";
  };

  # Frontend assets: pnpm build of web/ produces web/dist.
  web = pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
    pname = "utopia-web";
    inherit version;
    src = "${src}/web";

    pnpmDeps = pkgs.fetchPnpmDeps {
      inherit (finalAttrs) pname version src;
      fetcherVersion = 4;
      hash = "sha256-TIM43hImwOs3z+mBK6Cyea6hbx7a2VzbwnO1ummFVQg=";
    };

    nativeBuildInputs = [
      pkgs.nodejs
      pkgs.pnpmConfigHook
      pkgs.pnpm
    ];

    buildPhase = ''
      runHook preBuild
      pnpm build
      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall
      mkdir -p $out/share/utopia
      cp -r dist $out/share/utopia/web
      runHook postInstall
    '';
  });

  # utopia-server embeds web/src/docs/*.md and web/src/palette.ts via
  # include_str!, so the full web/ source tree must be present at build time.
  server = pkgs.rustPlatform.buildRustPackage {
    pname = "utopia-server";
    inherit version src;

    cargoLock = {
      lockFile = "${src}/Cargo.lock";
    };

    cargoBuildFlags = [ "-p" "utopia-server" ];

    nativeBuildInputs = [ pkgs.pkg-config ];

    buildInputs = [
      pkgs.openssl
      pkgs.sqlite
    ];

    doCheck = false;

    # docs_corpus.rs pulls in web/src/docs, so web source must be vendored.
    preBuild = ''
      mkdir -p web/src
      cp -r ${src}/web/src/docs web/src/docs 2>/dev/null || true
      cp ${src}/web/src/palette.ts web/src/palette.ts 2>/dev/null || true
    '';

    postInstall = ''
      mkdir -p $out/share/utopia
      cp -r ${web}/share/utopia/web $out/share/utopia/web
    '';

    meta = with lib; {
      homepage = "https://github.com/deeplethe/utopia";
      description = "Utopia ontology service server";
      license = licenses.asl20;
      mainProgram = "utopia-server";
      platforms = platforms.unix;
    };
  };
in
server