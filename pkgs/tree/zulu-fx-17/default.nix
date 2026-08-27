{pkgs, ...}:
(pkgs.zulu17.overrideAttrs (prev: {
    # failed to launch some gtk tools workaround.
    nativeBuildInputs = prev.nativeBuildInputs ++ [
      pkgs.wrapGAppsHook3
    ];
  })).override { enableJavaFX = true; dists.x86_64-linux = {
    zuluVersion = "17.68.17";
    jdkVersion = "17.0.20";
    hash = "sha256-+y88gUlXujPMhTX/iwzy1LcITdabVsfx4xGVETDDJD8=";
  };
}
