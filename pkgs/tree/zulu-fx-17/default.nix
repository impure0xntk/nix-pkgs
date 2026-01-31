{pkgs, ...}:
(pkgs.zulu17.overrideAttrs (prev: {
    # failed to launch some gtk tools workaround.
    nativeBuildInputs = prev.nativeBuildInputs ++ [
      pkgs.wrapGAppsHook3
    ];
  })).override { enableJavaFX = true; dists.x86_64-linux = {
    zuluVersion = "17.64.17";
    jdkVersion = "17.0.18";
    hash = "sha256-jQ2ByIKtivoc9nJ/LPMZCktyjceqXY+B6a36sXmwUbE=";
  };
}
