# Azul Zulu 25 LTS with JavaFX, newer than nixpkgs pin.
# Same pattern as zulu-fx-17: wrapGAppsHook3 for gtk tools + FX dist override.
{pkgs, ...}:
(pkgs.zulu25.overrideAttrs (prev: {
  # failed to launch some gtk tools workaround.
  nativeBuildInputs = prev.nativeBuildInputs ++ [
    pkgs.wrapGAppsHook3
  ];
})).override {
  enableJavaFX = true;
  dists = {
    x86_64-linux = {
      zuluVersion = "25.38.201";
      jdkVersion = "25.0.5.1";
      hash = "sha256-67gtw2oUCWg60BkRraKBh+uk5VMJmmk1C+axJQycWdA=";
    };
    aarch64-linux = {
      zuluVersion = "25.38.201";
      jdkVersion = "25.0.5.1";
      hash = "sha256-tLWc75HifU3htjIRLg6Kofyd0cvysbHvHrREWFefov8=";
    };
  };
}
