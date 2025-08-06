{pkgs, ...}:
(pkgs.zulu17.overrideAttrs (prev: {
    # failed to launch some gtk tools workaround.
    nativeBuildInputs = prev.nativeBuildInputs ++ [
      pkgs.wrapGAppsHook
    ];
  })).override { enableJavaFX = true; dists.x86_64-linux = {
    zuluVersion = "17.60.17";
    jdkVersion = "17.0.16";
    hash = "sha256-DWpICuPjCCE0Z21skCTq5V5JdBcujDDsiKfQIH6ngY4=";
  };
}
