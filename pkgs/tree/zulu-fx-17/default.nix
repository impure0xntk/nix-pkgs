{pkgs, ...}:
(pkgs.zulu17.overrideAttrs (prev: {
    # failed to launch some gtk tools workaround.
    nativeBuildInputs = prev.nativeBuildInputs ++ [
      pkgs.wrapGAppsHook3
    ];
  })).override { enableJavaFX = true; dists.x86_64-linux = {
    zuluVersion = "17.62.17";
    jdkVersion = "17.0.17";
    hash = "sha256-Ghb5NELt5p07HmnXjQvPmUU5cWdceuFH+aT+UwyaT9k=";
  };
}
