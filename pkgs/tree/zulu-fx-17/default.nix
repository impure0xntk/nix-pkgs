{pkgs, ...}:
(pkgs.zulu17.overrideAttrs (prev: {
    # failed to launch some gtk tools workaround.
    nativeBuildInputs = prev.nativeBuildInputs ++ [
      pkgs.wrapGAppsHook3
    ];
  })).override { enableJavaFX = true; dists.x86_64-linux = {
    zuluVersion = "17.66.19";
    jdkVersion = "17.0.19";
    hash = "sha256-FCp5FoevH8ekD+AZhapvcqc8EpD08ubJ+UFCzwzDWJQ=";
  };
}
