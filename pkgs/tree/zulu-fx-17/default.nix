{pkgs, ...}:
(pkgs.zulu17.overrideAttrs (prev: {
    # failed to launch some gtk tools workaround.
    nativeBuildInputs = prev.nativeBuildInputs ++ [
      pkgs.wrapGAppsHook3
    ];
  })).override { enableJavaFX = true; dists.x86_64-linux = {
    zuluVersion = "17.68.203";
    jdkVersion = "17.0.20.1";
    hash = "sha256-2a7mYwSmR+C6x/cyYk/6wrDFKWI4kpHAjqzwC8N3lEM=";
  };
}
