{pkgs, ...}:
(pkgs.zulu17.overrideAttrs (prev: {
    # failed to launch some gtk tools workaround.
    nativeBuildInputs = prev.nativeBuildInputs ++ [
      pkgs.wrapGAppsHook3
    ];
  })).override { enableJavaFX = true; dists.x86_64-linux = {
    zuluVersion = "17.70.113";
    jdkVersion = "17.0.21.0.3";
    hash = "sha256-UzfgUH7VOfHDX54NPEx2adWUpm5ay5N/hLZal3ehTr0=";
  };
}
