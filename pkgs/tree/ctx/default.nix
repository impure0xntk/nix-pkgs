{
  pkgs,
  lib,
  ...
}:
pkgs.rustPlatform.buildRustPackage (
  finalAttrs: {
    pname = "ctx";
    version = "2.0.4";

    src = pkgs.fetchFromGitHub {
      owner = "ctxrs";
      repo = "ctx";
      tag = "v${finalAttrs.version}";
      hash = "sha256-sBTFkC+bAS0W+L+kZXupazRX/wzCS79aQ9ToLV0zks4=";
    };

    cargoHash = "sha256-v4S5IUigkH8ScNbbRsS0DPMbLs6ub7Q1oXpc8EapH3o=";

    # The workspace has ~200 members; only the CLI binary is shipped.
    cargoBuildFlags = [
      "--package"
      "ctx"
    ];

    # CoreML acquisition tests fail in the Nix sandbox.
    doCheck = false;

    doInstallCheck = true;
    preInstallCheck = ''
      # ctx touches its data root on first run, so the check needs a writable HOME.
      export HOME="$TMPDIR/home"
      mkdir -p "$HOME"
    '';
    nativeInstallCheckInputs = [ pkgs.versionCheckHook ];

    meta = {
      description = "Search coding agent history already on your machine";
      homepage = "https://github.com/ctxrs/ctx";
      license = lib.licenses.asl20;
      mainProgram = "ctx";
      platforms = lib.platforms.unix;
    };
  }
)
