{pkgs, ...}:
(pkgs.zulu17.overrideAttrs (prev: {
    # failed to launch some gtk tools workaround.
    nativeBuildInputs = prev.nativeBuildInputs ++ [
      pkgs.wrapGAppsHook
    ];
  })).override { enableJavaFX = true; dists.x86_64-linux = {
    zuluVersion = "17.58.21";
    jdkVersion = "17.0.15";
    hash = "sha256-QuJzH8zvRbcNYD9mRtxnl2IH3Mf2n63LG5JTJ2AJ0hE=";
  };
}
