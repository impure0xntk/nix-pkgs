# https://github.com/natsukagami/nix-home/blob/bd5acf3921e193f0e64383bcb9e4796b66f169ba/packages/common/vikunja.nix#L30
# TODO: Remove after NixOS 26.05
{
  pkgs,
  lib,
  ...
}:
let
  version = "1.0.0-rc3";
  src = pkgs.fetchFromGitHub {
    owner = "go-vikunja";
    repo = "vikunja";
    rev = "v${version}";
    sha256 = "sha256-YetKB3neWvRp0043c9XLulRUpbJqioHSrqanzWrTM8M=";
  };
  frontend = pkgs.stdenv.mkDerivation (finalAttrs: {
    pname = "vikunja-frontend";
    inherit version src;

    patches = [ ];

    sourceRoot = "${finalAttrs.src.name}/frontend";

    pnpmDeps = pkgs.fetchPnpmDeps {
      inherit (finalAttrs)
        pname
        version
        patches
        src
        sourceRoot
        ;
      fetcherVersion = 1;
      hash = "sha256-dC35ILN9gxonwAB4xqWcQhpoKkG8s3+sjjhuHF5UhNY=";
    };

    nativeBuildInputs = with pkgs; [
      nodejs
      pnpm
      pnpmConfigHook
    ];

    doCheck = false;

    preBuild = ''
      # using sass-embedded fails at executing node_modules/sass-embedded-linux-x64/dart-sass/src/dart
      rm -r node_modules/sass-embedded*
      rm -r node_modules/.pnpm/sass-embedded*
    '';

    postBuild = ''
      pnpm run build
    '';

    checkPhase = ''
      pnpm run test:unit --run
    '';

    installPhase = ''
      cp -r dist/ $out
    '';
  });
in
pkgs.vikunja.overrideAttrs (old: {
  inherit src version frontend;
  doCheck = false;
  vendorHash = "sha256-p1IKRznebodPv8YojU/z5n3CtkObX310GAnuEvry8yk=";

  # To set version correctly in vikunja binary via "go build"
  nativeBuildInputs =
    let
      fakeGit = pkgs.writeShellScriptBin "git" ''
        if [[ $@ = "describe --tags --always --abbrev=10" ]]; then
            echo "${version}"
        else
            >&2 echo "Unknown command: $@"
            exit 1
        fi
      '';
    in
    with pkgs; [
      fakeGit
      mage
      go
    ];
})
